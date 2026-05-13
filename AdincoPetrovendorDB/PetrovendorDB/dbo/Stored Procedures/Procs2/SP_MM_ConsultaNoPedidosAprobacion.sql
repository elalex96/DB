USE [Petrovendor]
GO
DROP PROCEDURE IF EXISTS [SP_MM_ConsultaNoPedidosAprobacion]
/****** Object:  StoredProcedure [dbo].[MM_SP_ConsultaPedidoNotificacion]    Script Date: 25/03/2025 11:28:03 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel Cruz
-- Create date: 08-08-17
-- Description:	Consulta No. de Pedido de una aprobación 
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaNoPedidosAprobacion] 
	 
@IdOperacion int 
 

AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;
		 	
		DECLARE @Cadena NVARCHAR(MAX)
		SELECT
		@Cadena = COALESCE(@Cadena + ',','')+CAST(PG.IdPedido AS NVARCHAR(50)) 
		FROM dbo.TA_Operacion O
		INNER JOIN dbo.MM_Pedido P 
			ON  O.IdDocumento=P.IdSolicitudPedido 
		INNER JOIN dbo.MM_Pedidos PG 
			ON P.IdPedido = PG.IdIdentificador 
			AND P.IdProveedorCompras=PG.IdProveedorCliente
			AND PG.IdTipoPedido IN (2,4,6) --> CTES MERCADEO, ADJU DIRECTA, CONTROL OBRA DESCARTADO COLISIÓN CON COMPRA DIRECTA
		 WHERE O.IdOperacion= @IdOperacion	
		AND O.NoVersion=P.Version

		SELECT ISNULL(@Cadena,'')

	
END;




	