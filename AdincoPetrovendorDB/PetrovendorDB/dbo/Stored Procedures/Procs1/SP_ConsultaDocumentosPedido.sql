-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <12-12-2018>
-- Description:	<Carga el grid de los documentos anexos filtrado por pedido y version>
-- =============================================

CREATE PROCEDURE SP_ConsultaDocumentosPedido @IdPedido INT, @Version INT ,
												/*--------------------parametros contrato  --------------------*/
											 @IdContrato INT = NULL, @IdUsuario INT = NULL ,
											 @FechaRegistro DATETIME = NULL
/*-------------------------------------------------------------*/
AS
	BEGIN
		SELECT	Id, NombreDocumento, CreadoEl
		FROM	dbo.DocumentosPedido
		WHERE
				IdPedido = @IdPedido
				AND Version = @Version
				AND Activo = 1
	END