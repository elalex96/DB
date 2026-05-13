
Create Proc [dbo].[sp_SC_EliminarAdjunto]
@pIdSCAdjunto int
As

	delete SC_Adjunto
	where IdAdjunto = @pIdSCAdjunto
