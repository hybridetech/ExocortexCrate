/**********************************************************************
 *<
	FILE: AlembicVisCtrl.h

	DESCRIPTION:

	CREATED BY: Tom Hudson

	HISTORY:

 *>	Copyright (c) 1996, All Rights Reserved.
 **********************************************************************/

#ifndef __AlembicVisCtrl__H
#define __AlembicVisCtrl__H

#include "Max.h"
#include "resource.h"

#define ALEMBICVISCTRL_REF_PBLOCK 0

extern ClassDesc* GetAlembicVisCtrlClassDesc();

TCHAR *GetString(int id);
extern HINSTANCE hInstance;

void AlembicImport_SetupVisControl( Alembic::AbcGeom::IObject &obj, INode *pNode, alembic_importoptions &options );

#endif
