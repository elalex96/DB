IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'ObtenerReporteDiarioOperacion'
)
    DROP PROCEDURE ObtenerReporteDiarioOperacion
GO
CREATE PROCEDURE [dbo].[ObtenerReporteDiarioOperacion]
    @IdContrato INT,
    @FechaInicio DATETIME,
    @FechaFin DATETIME
AS
BEGIN
    SELECT PR_ProdDiariaPozo_Previo.Fecha,
           PD_Campo.NombreCampo as Macropera,
           CO_Instalacion.NombreInstalacion AS Pozo,
           PR_Unidades.NombreUnidad,
           PR_ProdDiariaPozo_Previo.Fuente AS Estado,
           PR_Sistemas.NombreSistema,
           Round(PR_ProdDiariaPozo_Previo.ProdPetroleoBruto, 1) as BrutaBPD,
           Round(PR_ProdDiariaPozo_Previo.Agua, 1) as Agua,
           Round(PR_ProdDiariaPozo_Previo.ProdAceiteNeto, 1) as NetaBPD,
           Round(PR_ProdDiariaPozo_Previo.GastoGas, 1) as GastoGas,
           Round(PR_ProdDiariaPozo_Previo.Cabeza, 1) as TP,
           Round(PR_ProdDiariaPozo_Previo.Linea, 1) as TR,
           Round(PR_ProdDiariaPozo_Previo.Est_64Plg, 1) as Carrera,
           Round(PR_ProdDiariaPozo_Previo.EPM, 1) as EPM,
           PR_ProdDiariaPozo_Previo.NombreEstacion as SuministroGas,
           PR_ProdDiariaPozo_Previo.Nominal as Consumo,
           PR_Tanque.Nombre as Fluye,
           PR_ProdDiariaPozo_Previo.Comentarios,
		   PR_ProdDiariaPozo_Previo.ProgramaInmediato,
		   PR_ProdDiariaPozo_Previo.Seguimiento
    FROM PR_ProdDiaria_Previo (NOLOCK)
        INNER JOIN PR_BLOQUE (NOLOCK)
            ON PR_ProdDiaria_Previo.Bloque = PR_BLOQUE.Id
               AND PR_BLOQUE.IdContrato = @IdContrato
        INNER JOIN PR_ProdDiariaPozo_Previo (NOLOCK)
            ON PR_ProdDiaria_Previo.Id = PR_ProdDiariaPozo_Previo.ProdDiaria
        LEFT JOIN CO_Instalacion (NOLOCK)
            ON PR_ProdDiariaPozo_Previo.Pozo = CO_Instalacion.WelIID
        LEFT JOIN PR_Unidades (NOLOCK)
            ON PR_ProdDiariaPozo_Previo.IdUnidad = PR_Unidades.IdUnidad
        LEFT JOIN PR_Sistemas (NOLOCK)
            ON PR_ProdDiariaPozo_Previo.IdSistema = PR_Sistemas.IdSistema
		LEFT JOIN PR_Tanque (NOLOCK)
			ON PR_ProdDiariaPozo_Previo.Estacion = PR_Tanque.Id
		INNER JOIN PD_Campo (NOLOCK)
			ON CO_Instalacion.IdCampo = PD_Campo.IdCampo
    WHERE PR_ProdDiaria_Previo.Fecha
    BETWEEN DATEADD(DAY, -1, @FechaInicio) AND  @FechaFin
	ORDER BY PR_ProdDiariaPozo_Previo.Fecha, PD_Campo.NombreCampo, CO_Instalacion.NombreInstalacion
END




