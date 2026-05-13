-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <17-09-2018>
-- Description:	<Se agrega el bit de activo>
-- =============================================
-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 12-05-17
-- Description:	 Consultar DOCUMENTOS DE ACEPTACIÓN DE DOCUMENTOS
-- CAMBIO DE REFERENCIA DE DE S_DOCUMENTOS A S_DOCUMENTOS_S3 DANIEL AC 08/05/2018
-- =============================================

CREATE procedure [dbo].[SP_MPY_PR_MM_PCN_AceptacionProveedorDocumentos]
	-- Add the parameters for the stored procedure here
	@IdProveedor INT, @IdAceptacionPedido INT, @Accion NVARCHAR(MAX), @IdDocumento INT
AS
	BEGIN
		SET NOCOUNT ON 

		IF @Accion = 'TABLA'
			BEGIN
				SELECT		AD.[IdDocumento], AD.[NombreDocumento], AD.[Comentario]
				FROM		[dbo].[MM_AceptacionDocumento] AS AD
				INNER JOIN	[dbo].[MPY_MM_AceptacionPedido] AS AP
					ON AP.[IdAceptacionPedido] = AD.[IdAceptacionDocumento]
				WHERE
							AP.[IdAceptacionPedido] = @IdAceptacionPedido
							AND AP.[IdProveedor] = @IdProveedor
							AND AD.[IdDocumento] IS NOT NULL
							AND AD.Activo = 1
			END

		IF @Accion = 'DESCARGA'
			BEGIN
				SELECT		AD.[IdDocumento], AD.[NombreDocumento], '' AS Documento, D.[Carpeta], D.[Extension] ,
							D.Identificador
				FROM		[dbo].[MM_AceptacionDocumento] AS AD
				INNER JOIN	[dbo].[MPY_MM_AceptacionPedido] AS AP
					ON AP.[IdAceptacionPedido] = AD.[IdAceptacionDocumento]
				INNER JOIN	[dbo].[S_Documento_S3] AS D
					ON D.[IdDocumento] = AD.[IdDocumento]
				WHERE
							AP.[IdAceptacionPedido] = @IdAceptacionPedido
							AND AP.[IdProveedor] = @IdProveedor
							AND AD.[IdDocumento] = @IdDocumento
							AND AD.Activo = 1
			END
	END
