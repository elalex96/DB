-- =============================================
-- Author:	DANIEL AC
-- Create date: 07/03/2018
-- Description:	Agregar archivo por solicitud pedido detalle 
-- =============================================
-- =============================================
-- Author:	Pedro Acuña
-- Create date: 17/09/2018
-- Description:	se agrega el bit de activo 
-- =============================================

CREATE PROCEDURE [dbo].[API_SP_MM_AgregarArchivoPorMaterialSolPed] @IdSolPedDetalle INT, @ArchivoAdjunto NVARCHAR(MAX) ,
																   @NombreAdjunto NVARCHAR(MAX)
AS
	BEGIN
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		SET NOCOUNT ON ;

		INSERT INTO MM_SolPedArchivoAdjuntoMaterial
			( IdSolPedDetalle, ArchivoAdjuntoMaterial, NombreArchivoAdjunto, Activo )
		VALUES
			( @IdSolPedDetalle, @ArchivoAdjunto, @NombreAdjunto, 1 )

		SELECT @@IDENTITY
	END