#include "syntax_tree.h"

Node* newNode(const char * name, int line, char* contain, bool isToken)
{
    Node* node=(Node*)malloc(sizeof(Node));
    node->name = malloc(sizeof(char)*strlen(name));
    strcpy(node->name,name);
    node->line=line;
    node->childNum=0;

    // 对于词法元素节点需要进行更多操作
    if(isToken)
    {
        if(!strcmp(name,"ID") || !strcmp(name,"TYPE"))
        {
            node->info.idTypeVal = malloc(sizeof(char)*strlen(contain));
            strcpy(node->info.idTypeVal,contain);
        }
        else if(!strcmp(name,"INT"))
        {
            if(contain[1] == 'x')
            {
                int ans=0;
                for(int i=1;contain[i]!='\0';i++)
                {
                    if(contain[i]>='0' && contain[i]<='9')
                        ans=ans*16+contain[i]-'0';
                    else if(contain[i]>='a' && contain[i]<='f')
                        ans=ans*16+contain[i]-'a'+10;
                    else if(contain[i]>='A' && contain[i]<='F')
                        ans=ans*16+contain[i]-'A'+10;
                }
                node->info.intVal=ans;
            }
            else if(contain[0] == '0')
            {
                int ans=0;
                for(int i=1;contain[i]!='\0';i++)
                    ans=ans*8+contain[i]-'0';
                node->info.intVal=ans;
            }
            else 
                node->info.intVal=atoi(contain); // 十进制
        }
        else if(!strcmp(name,"FLOAT"))
            node->info.floatVal=atof(contain);
    }
    return node;
}


void addChild(Node* parent, Node* child)
{
	parent->child[parent->childNum++]=child;
}


Tree* newTree()
{
    return (Tree*)malloc(sizeof(Tree));
}


void printTree(Tree* tree)
{
    printTreeNode(tree->root,0);
}


void printTreeNode(Node* node, int level)
{
    if(node==NULL) 
        return;
	
	for (int i=0;i<level;i++) 
	    printf("  ");

    // 词法元素与语法元素节点输出不同
    if(node->name[1]<='z' && node->name[1]>='a')
        printf("%s (%d)",node->name,node->line);
    else    
        printf("%s",node->name);
    
    if(!strcmp(node->name,"ID") || !strcmp(node->name,"TYPE"))
        printf(": %s",node->info.idTypeVal);
    else if(!strcmp(node->name,"INT"))
        printf(": %d",node->info.intVal);
    else if(!strcmp(node->name,"FLOAT"))
        printf(": %lf",node->info.floatVal);

    printf("\n");
	for (int i=0; i<node->childNum; i++)
		printTreeNode(node->child[i],level+1);
}

// 语法分析中用于构建语法树的函数，使用到了前面创建结点与插入子结点的函数
Node* createNodeWithChild(const char *name, int line, int childNum, ...)
{
    Node *node = newNode(name, line, NULL, false);
    Node *child;

    va_list ap;
    va_start(ap, childNum);
    for (int i=0; i<childNum; i++) {
        child = va_arg(ap, Node*);
        addChild(node, child);
    }
    va_end(ap);

    return node;
}
