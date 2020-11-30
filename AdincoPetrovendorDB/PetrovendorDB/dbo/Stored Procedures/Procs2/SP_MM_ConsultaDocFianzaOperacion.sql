-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <17-09-2018>
-- Description:	<Se agrega el bit de activo>
-- =============================================
-- =============================================
-- Author:		Josue Glez
-- Create date:  05/9/2017
-- Description:	Obtiene documeto de fianza a partir de una solicitud de pedido en proceso de oferta
-- Update: 09/05/2018 Daniel AC se agrega parametros de identificación en S3
-- =============================================

CREATE PROCEDURE [dbo].[SP_MM_ConsultaDocFianzaOperacion] @IdSolicitudPedido INT
AS
	BEGIN
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		SET NOCOUNT ON ;

		SELECT		F.IdDocFianza, '' AS Documento, F.IdOperacion, f.NombreDoc, F.Carpeta, F.Identificador, F.Mime ,
					F.Extension
		FROM		[TA_DocFianzaOperacion] F
		LEFT JOIN	TA_Operacion O
			ON F.Idoperacion = O.IdOperacion
		LEFT JOIN	MM_SolicitudPedido SP
			ON O.IdDocumento = SP.IdSolicitudPedido
		WHERE
					O.IdTipoOperacion = 6
					AND SP.IdSolicitudPedido = @IdSolicitudPedido
					AND F.Activo = 1
	END