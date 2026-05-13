USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_MM_ValidacionEdicionPedido'
)
    DROP PROCEDURE SP_MM_ValidacionEdicionPedido;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 13/10/2022
-- Description: Validacion de edicion de pedido
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 21/11/2023
-- Description: Mejora en validacion
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ValidacionEdicionPedido] 
	-- Add the parameters for the stored procedure here
	 @IdPedido INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @PROCESOS_EN_CURSO INT = 0;

	CREATE TABLE #PROCESOS_PENDIENTES(
		Id INT PRIMARY KEY IDENTITY(1,1),
		IdProceso INT,
		Tipo NVARCHAR(20)
	);

	--SE OBTIENEN LA CANTIDAD DE CARTAS CN RELACIONADAS AL PEDIDO
	--SE OBTIENE LA CANTIDAD DE FACTURAS ASOCIADAS AL PEDIDO
	--SE OBTIENE LA CANTIDAD DE COMPROBANTES EXTRANJEROS
	INSERT INTO #PROCESOS_PENDIENTES (IdProceso,Tipo)
	SELECT
		ACN.IdAceptacionCartaPCN,
		'CARTACN'
	FROM MM_AceptacionCartaPCN AS ACN (NOLOCK)
		JOIN MM_AceptacionPedido AS AP (NOLOCK)
			ON ACN.IdAceptacionPedido = AP.IdAceptacionPedido
			AND ACN.Activo = 1
		JOIN MM_Pedido AS P (NOLOCK)
			ON AP.IdPedido = P.IdPedido
	WHERE P.IdPedido = @IdPedido
	UNION
	SELECT
		AF.IdAceptacionFactura,
		'FACTURA'
	FROM MM_AceptacionFactura AS AF (NOLOCK)
		JOIN MM_AceptacionPedido AS AP (NOLOCK)
			ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
			AND AF.IdEstatusEliminado IS NULL
		JOIN MM_Pedido AS P (NOLOCK)
			ON AP.IdPedido = P.IdPedido
	WHERE P.IdPedido = @IdPedido
	UNION
	SELECT
		AF.IdAceptacionPedidoPedimentoComprobante,
		'PEDIMENTO/COMPROBANTE'
	FROM FI_AceptacionPedido_PedimentoComprobante AS AF (NOLOCK)
		JOIN MM_AceptacionPedido AS AP (NOLOCK)
			ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
			AND AF.Activo = 1
		JOIN MM_Pedido AS P (NOLOCK)
			ON AP.IdPedido = P.IdPedido
	WHERE P.IdPedido = @IdPedido;

	SET @PROCESOS_EN_CURSO = (SELECT COUNT(Id) FROM #PROCESOS_PENDIENTES);

	IF @PROCESOS_EN_CURSO > 0
	BEGIN

		SELECT 0 AS EDICION_DISPONIBLE

	END
	ELSE
	BEGIN

		SELECT 1 AS EDICION_DISPONIBLE

	END

END
