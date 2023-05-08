-- =============================================
-- Author:	Alexander Gomez
-- Create date: 16/06/2017
-- Description:	Eliminar un detalle del material que se utilizar pa CPCN
-- =============================================
CREATE procedure [dbo].[SP_MPY_PCN_EliminarMaterialesUtilizados]

@IdMaterialServicioUtilizado INT,
@IdUsuario INT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	UPDATE dbo.MPY_MM_PCN_MaterialesUtilizados
	SET IsEliminado = 1,
	[EditadoPor]= @IdUsuario,
	[EditadoEl]=GETDATE()
	WHERE [IdMaterialServicioUtilizado]=@IdMaterialServicioUtilizado
	  
END

