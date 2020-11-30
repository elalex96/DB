-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <17-09-2018>
-- Description:	<Se agrega el bit de activo>
-- =============================================
-- =============================================
-- Author:		Josue Glez
-- Create date:  05/9/2017
-- Description:	Obtiene documeto de bases de licitacion a partir de una solicitud de pedido en proceso de oferta
-- Update: Se agregaron columnas de propiedades del documento para consulta del archivo
-- =============================================

CREATE PROCEDURE [dbo].[SP_MM_ConsultaDocBasesOperacion] @IdSolicitudPedido INT
AS
	BEGIN
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		SET NOCOUNT ON

		SELECT		F.IdDocBases, '' AS Documento, F.IdOperacion, F.Identificador, F.Carpeta, F.Extension, F.Mime
		FROM		TA_DocBasesOperacion F
		LEFT JOIN	TA_Operacion O
			ON F.Idoperacion = O.IdOperacion
		LEFT JOIN	MM_SolicitudPedido SP
			ON O.IdDocumento = SP.IdSolicitudPedido
		WHERE
					O.IdTipoOperacion = 6
					AND SP.IdSolicitudPedido = @IdSolicitudPedido
					AND F.Activo = 1
	END