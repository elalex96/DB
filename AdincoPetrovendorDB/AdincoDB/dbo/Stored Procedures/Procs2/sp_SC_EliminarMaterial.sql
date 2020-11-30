Create Proc [dbo].[sp_SC_EliminarMaterial]
@pIdSCMaterial int
as

delete SC_Materiales
where IdSCMaterial =@pIdSCMaterial
