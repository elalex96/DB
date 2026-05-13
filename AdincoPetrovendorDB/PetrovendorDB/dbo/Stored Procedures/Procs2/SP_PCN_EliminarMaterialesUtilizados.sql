-- =============================================
-- Author:	Daniel Ac
-- Create date: 14/11/2017
-- Description:	Eliminar un detalle del material que se utilizar pa CPCN
-- =============================================
CREATE PROCEDURE [dbo].[SP_PCN_EliminarMaterialesUtilizados]

@IdMaterialServicioUtilizado INT,
@IdUsuario INT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	UPDATE MM_PCN_MaterialesUtilizados
	SET IsEliminado = 1,
	[EditadoPor]= @IdUsuario,
	[EditadoEl]=GETDATE()
	WHERE [IdMaterialServicioUtilizado]=@IdMaterialServicioUtilizado
	  
END