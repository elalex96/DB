USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'FN_CantidadClientesSubContratista'
)
    DROP FUNCTION FN_CantidadClientesSubContratista;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <30/01/2020>
-- Description:	<Consultar la cantidad de operadores que le han hecho un pedido al subcontratista>
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <05/07/2023>
-- Description:	<Optimizacion del sp>
-- =============================================
CREATE FUNCTION [dbo].[FN_CantidadClientesSubContratista]
(
	-- Add the parameters for the function here
	@IdProveedor INT
)
RETURNS INT
AS
BEGIN
	-- Declare the return variable here
	DECLARE @CANTIDADCLIENTES INT;

	-- Add the T-SQL statements to compute the return value here
	DECLARE @reb TABLE (IDCLIENTE INT);

	INSERT INTO @reb
	SELECT 
		P.IdProveedorCompras
	FROM dbo.MM_Pedido AS P
		JOIN dbo.MM_AceptacionPedido AS AP (NOLOCK)
			ON P.IdPedido = AP.IdPedido
			AND P.IdSubcontratista = @IdProveedor
	GROUP BY P.IdProveedorCompras;

	SELECT
		@CANTIDADCLIENTES = COUNT(IDCLIENTE)
	FROM @reb

	-- Return the result of the function
	RETURN @CANTIDADCLIENTES;

END

