#ifndef __SYNTAXTREE_H__
#define __SYNTAXTREE_H__

#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>

// 记录词法单元的额外信息的联合体
union exInfo
{
	int intVal;
    float floatVal;
    char* idTypeVal;
}; 

// 语法树节点
typedef struct _Node{
	char* name;
	struct _Node * child[10];
	int childNum;
	union exInfo info;
	int line;
} Node;

// 语法树结构定义
typedef struct _Tree {
	Node* root;
} Tree;

// 语法树相关操作函数
Node* newNode(const char * name, int line, char* contain, bool isToken);
void addChild(Node* parent, Node* child);
Tree* newTree();
void printTree(Tree* tree);
void printTreeNode(Node* node, int level);
Node* createNodeWithChild(const char *name, int line, int childNum, ...);

#endif
