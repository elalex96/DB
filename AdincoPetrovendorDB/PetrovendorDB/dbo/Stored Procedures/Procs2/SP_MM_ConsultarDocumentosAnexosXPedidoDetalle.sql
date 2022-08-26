USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_MM_ConsultarDocumentosAnexosXPedidoDetalle'
)
DROP PROCEDURE SP_MM_ConsultarDocumentosAnexosXPedidoDetalle;
GO
/****** Object:  StoredProcedure [dbo].[SP_MM_ConsultarDocumentosAnexosXPedidoDetalle]    Script Date: 25/08/2022 01:03:03 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Daniel AC
-- Create date: <25/08/2022>
-- Description:	Optimización de sp
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultarDocumentosAnexosXPedidoDetalle]
	@IdPedido INT,
	@IdPedidoDetalle int
AS
BEGIN

	SELECT IdDocumentoAnexo, Nombre
	FROM MM_DocumentosAnexos (NOLOCK)
	WHERE IdPeticionOferta = @IdPedido
	AND IdPeticionOfertaDetalle = @IdPedidoDetalle
	AND Activo=1

END