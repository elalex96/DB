USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_SEL_SP_ConsultaMesesSolicitudPedido'
)
    DROP PROCEDURE USP_SEL_SP_ConsultaMesesSolicitudPedido;
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 02/09/2024
-- Description:	Obtención de meses en los que se tienen solicitudes de pedido
-- =============================================
CREATE PROCEDURE [dbo].[USP_SEL_SP_ConsultaMesesSolicitudPedido] --573,0,1
	-- Add the parameters for the stored procedure here
	@IdProveedor INT,
	@IdUsuario INT,
	@FechaFin BIT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET LANGUAGE Español;
	
    -- Insert statements for procedure here
	DECLARE @FECHA_INICIAL_CONTRATO DATE = (SELECT TOP 1 FechaAlta FROM MM_SolicitudPedido WHERE IdProveedor = @IdProveedor ORDER BY FechaAlta ASC),
			@FECHA_FINAL_CONTRATO DATE = (SELECT TOP 1 FechaAlta FROM MM_SolicitudPedido WHERE IdProveedor = @IdProveedor ORDER BY FechaAlta DESC),
			@FECHA_SIGUIENTE DATE;

	CREATE TABLE #FECHAS_MESES(
		Fecha DATE,
		FechaFin BIT
	);

	SET @FECHA_SIGUIENTE = DATEADD(DAY, 1, EOMONTH(@FECHA_INICIAL_CONTRATO, -1));

	INSERT INTO #FECHAS_MESES (Fecha,FechaFin) VALUES (@FECHA_SIGUIENTE,0);

	SET @FECHA_SIGUIENTE = DATEADD(month, 1,@FECHA_SIGUIENTE);
	WHILE @FECHA_SIGUIENTE <= @FECHA_FINAL_CONTRATO
	BEGIN
		SET @FECHA_SIGUIENTE = DATEADD(month, 1,@FECHA_SIGUIENTE);
		INSERT INTO #FECHAS_MESES (Fecha, FechaFin) VALUES (@FECHA_SIGUIENTE,0);
	END
	
	INSERT INTO #FECHAS_MESES (Fecha,FechaFin)
	SELECT 
		EOMONTH(Fecha),
		1
	FROM #FECHAS_MESES

	SELECT
		DATENAME(MONTH, Fecha) + ' ' + DATENAME(year, Fecha) AS MesesAnios,
		Fecha
	FROM #FECHAS_MESES
	WHERE FechaFin = @FechaFin
	ORDER BY Fecha DESC;

END
