-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20180818
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE COM_PrecioAplicaMeses --3,10000,'2018-08-01',10061,2.8
    @idContrato INT,
    @idTipoHidrocarburo INT,
    @Mes DATE,
    @IdUsuario INT,
    @PrecioUnitario FLOAT
AS
BEGIN

    SET NOCOUNT ON;
  
	IF OBJECT_ID('tempdb.dbo.#TemporalMeses', 'U') IS NOT NULL
	DROP TABLE #TemporalMeses; 

    SELECT Mes
    INTO #TemporalMeses
    FROM dbo.COM_CostoUnitarioHidrocarburo
    WHERE IdContrato = @idContrato
          AND IdTipoHidrocarburo = @idTipoHidrocarburo
          AND YEAR(Mes) = YEAR(@Mes);

	IF OBJECT_ID('tempdb.dbo.#TemporalMesesAplica', 'U') IS NOT NULL
	DROP TABLE #TemporalMesesAplica; 
 
    SELECT IdFecha
	INTO #TemporalMesesAplica
    FROM dbo.AP_Calendario
    WHERE Anio = YEAR(@Mes)
          AND Dia = 1
          AND IdFecha NOT IN (
                                 SELECT Mes FROM #TemporalMeses
                             );
INSERT INTO dbo.COM_CostoUnitarioHidrocarburo
(
    IdContrato,
    Mes,
    IdTipoHidrocarburo,
    CostoUnitarioComercializacion,
    CreadoPor,
    CreadoEl
)(
 SELECT 
   @idContrato,				-- IdContrato - int
    IdFecha,					-- date
    @idTipoHidrocarburo,	-- IdTipoHidrocarburo - int
	@PrecioUnitario,		-- CostoUnitarioComercializacion - money
    @IdUsuario,				-- CreadoPor - int
    GETDATE()				-- CreadoEl - datetime
  FROM #TemporalMesesAplica);


END;