#ifndef _ALEMBIC_POINTSUTILS_H_
#define _ALEMBIC_POINTSUTILS_H_

#include "AlembicMax.h"
#include <vector>

struct particleMeshData{
	BOOL bNeedDelete;
	Mesh* pMesh;
	Mtl* pMtl;
	AnimHandle animHandle;//needed to uniquely identifiy particle groups
	Matrix3 worldTrans;
};

void getParticleSystemRenderMeshes(TimeValue ticks, Object* obj, INode* node, std::vector<particleMeshData>& meshes);

#endif
