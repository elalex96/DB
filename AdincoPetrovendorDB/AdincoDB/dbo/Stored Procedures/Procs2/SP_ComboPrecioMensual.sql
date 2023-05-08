CREATE PROCEDURE [dbo].SP_ComboPrecioMensual
@IdContrato INT = 0,
@MarcadorId INT = 0
AS  
	BEGIN    
         SET NOCOUNT ON;  
         SET LANGUAGE spanish;  
	 
	 DECLARE @FechaEfectiva DATE	

     SELECT @FechaEfectiva = InicioVigencia
         FROM dbo.CO_Contrato
         WHERE IdContrato = @IdContrato;

	
	SELECT	
			CAST(AP_Calendario.IdFecha AS DATE) AS IdFecha, 
			CONCAT(RIGHT('00'+CAST(MONTH(AP_Calendario.Dia) AS VARCHAR(2)), 2), ' ', DATENAME(MONTH, AP_Calendario.IdFecha), ' ', YEAR(AP_Calendario.IdFecha)) AS Fecha
	FROM AP_Calendario  
	LEFT JOIN CO_PrecioMarcadorMensual 
		ON  CONVERT( varchar,AP_Calendario.IdFecha, 112) =  CONVERT( varchar,CO_PrecioMarcadorMensual.Mes, 112)
		AND IdContrato = @IdContrato
		AND IdMarcador = @MarcadorId
	WHERE AP_Calendario.Dia = 1 
	AND AP_Calendario.IdFecha BETWEEN @FechaEfectiva  AND CURRENT_TIMESTAMP 
	AND CO_PrecioMarcadorMensual.Mes IS NULL
	ORDER BY AP_Calendario.IdFecha

     END;