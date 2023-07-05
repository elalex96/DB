USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'FN_PedidosSubContratista'
)
    DROP FUNCTION FN_PedidosSubContratista;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <30/01/2020>
-- Description:	<funcion para obtener todos los pedidos realizados por el subcontratista>
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <05/07/2023>
-- Description:	<Optimizacion del sp>
-- =============================================
CREATE FUNCTION [dbo].[FN_PedidosSubContratista]
(
	-- Add the parameters for the function here
	@IdProveedor INT
)
RETURNS INT
AS
BEGIN
	-- Declare the return variable here
	DECLARE @CANTIDADPEDIDOSACEPTADOS INT;
	DECLARE @MESESATRAS DATETIME = DATEADD(MONTH,-5,GETDATE());
	DECLARE @REG TABLE (IDPEDIDO INT);
	-- Add the T-SQL statements to compute the return value here
	INSERT INTO @REG
	SELECT 
		P.IdPedido
	FROM dbo.MM_Pedido AS P (NOLOCK)
		JOIN dbo.MM_AceptacionPedido AS AP (NOLOCK)
			ON P.IdPedido = AP.IdPedido
			AND P.IdSubcontratista = @IdProveedor
	WHERE P.CreadoEl >= @MESESATRAS   
	GROUP BY P.IdPedido;

	SELECT
		@CANTIDADPEDIDOSACEPTADOS = COUNT(IDPEDIDO)
	FROM @REG

	-- Return the result of the function
	RETURN @CANTIDADPEDIDOSACEPTADOS;

END

