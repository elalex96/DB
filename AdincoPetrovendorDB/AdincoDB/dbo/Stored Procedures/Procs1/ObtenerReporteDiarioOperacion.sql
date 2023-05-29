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
           PR_ProdDiariaPozo_Previo.ProdPetroleoBruto as BrutaBPD,
           PR_ProdDiariaPozo_Previo.Agua,
           Round(PR_ProdDiariaPozo_Previo.ProdAceiteNeto, 0) as NetaBPD,
           PR_ProdDiariaPozo_Previo.GastoGas,
           PR_ProdDiariaPozo_Previo.Cabeza as TP,
           PR_ProdDiariaPozo_Previo.Linea as TR,
           PR_ProdDiariaPozo_Previo.Est_64Plg as Carrera,
           PR_ProdDiariaPozo_Previo.EPM,
           PR_ProdDiariaPozo_Previo.NombreEstacion as SuministroGas,
           PR_ProdDiariaPozo_Previo.Nominal as Consumo,
           ISNULL(PR_Tanque.Clave, '-') as Fluye,
           PR_ProdDiariaPozo_Previo.Comentarios,
		   PR_ProdDiariaPozo_Previo.ProgramaInmediato,
		   PR_ProdDiariaPozo_Previo.Seguimiento
    FROM PR_ProdDiaria_Previo (NOLOCK)
        INNER JOIN PR_BLOQUE (NOLOCK)
            ON PR_ProdDiaria_Previo.Bloque = PR_BLOQUE.Id
               AND PR_BLOQUE.IdContrato = @IdContrato
        INNER JOIN PR_ProdDiariaPozo_Previo (NOLOCK)
            ON PR_ProdDiaria_Previo.Id = PR_ProdDiariaPozo_Previo.ProdDiaria
        INNER JOIN CO_Instalacion (NOLOCK)
            ON PR_ProdDiariaPozo_Previo.Pozo = CO_Instalacion.WelIID
        INNER JOIN PR_Unidades (NOLOCK)
            ON PR_ProdDiariaPozo_Previo.IdUnidad = PR_Unidades.IdUnidad
        INNER JOIN PR_Sistemas (NOLOCK)
            ON PR_ProdDiariaPozo_Previo.IdSistema = PR_Sistemas.IdSistema
		LEFT JOIN PR_Tanque (NOLOCK)
			ON PR_ProdDiariaPozo_Previo.Estacion = PR_Tanque.Id
		INNER JOIN PD_Campo (NOLOCK)
			ON CO_Instalacion.IdCampo = PD_Campo.IdCampo
    WHERE PR_ProdDiaria_Previo.Fecha
    BETWEEN DATEADD(DAY, -1, @FechaInicio) AND  @FechaFin
	ORDER BY PR_ProdDiariaPozo_Previo.Fecha, PD_Campo.NombreCampo, CO_Instalacion.NombreInstalacion
END









