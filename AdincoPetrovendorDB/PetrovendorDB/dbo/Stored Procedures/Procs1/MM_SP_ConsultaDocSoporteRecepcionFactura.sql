USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[MM_SP_ConsultaDocSoporteRecepcionFactura]    Script Date: 12/10/2021 12:18:18 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Jose Roman>
-- Create date: <01-04-2018>
-- Description:	<Consulta para los documentos de soporte de recepcion de factura.>
-- =============================================

CREATE procedure [dbo].[MM_SP_ConsultaDocSoporteRecepcionFactura]
	@IdAceptacionPedido INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	SELECT 
		DSF.IdDocSoporteRecepcionFactura,
		DSF.NombreDoc,
		DSF.Comentario,
		DSF.CargadoEl,
		US.Nombre
	FROM dbo.MM_DocSoporteRecepcionFactura AS DSF
	LEFT JOIN S_Usuario AS US 
		ON DSF.CargadoPor = US.IdUsuario
	WHERE IdAceptacionPedido = @IdAceptacionPedido
		AND Eliminado = 0;
END
