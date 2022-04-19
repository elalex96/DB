-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 19/04/2022
-- Description:	Consulta para validar si el proveedor tiene Pedidos a los contratos de WDEA
-- =============================================
CREATE PROCEDURE SP_MM_ValidarProveedorPedidosWDEA
	-- Add the parameters for the stored procedure here
	@IdProveedor INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		CAST((CASE	
			WHEN COUNT(P.IdPedido) = 0 THEN 0
			WHEN COUNT(P.IdPedido) > 0 THEN 1
		END) AS bit) AS EsProveedorWDEA
	FROM DEA_Proveedor AS PRDEA
	JOIN MM_Pedido AS P 
		ON PRDEA.IdProveedor = P.IdProveedorCompras
		AND P.IdSubcontratista = @IdProveedor;

END
GO
