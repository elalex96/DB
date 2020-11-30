-- DROP TABLE #PruebaFechas;

-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20181023
-- Description:	EXTRAE VALORES PARA NOTAS 
-- =============================================
CREATE PROCEDURE sp_CuadroTextosVariacion-- 10019,10061,2,'20181030'--SIMULACION  Fecha Inicial
    @idContrato INT,
    @idUsuario INT,
    @idHidrocarburo INT,
	@Fecha Date
AS
BEGIN


    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb.dbo.#SumaNominacion', 'U') IS NOT NULL
        DROP TABLE #SumaNominacion;


    CREATE TABLE #SumaNominacion
    (
        Suma FLOAT,
        idFecha DATE
    );


    IF (@idHidrocarburo = 1) -------------------------GAS
    BEGIN
        INSERT INTO #SumaNominacion
        (
            Suma,
            idFecha
        )
        SELECT SUM(VolumenProgramado),
               idFecha
        FROM CO_NominacionVolumen N
            JOIN CO_PuntosdeEntregaContrato PTC
                ON N.puntoEntregaId = PTC.PuntoEntregaID
                   AND N.idProductoNominacion = 1000
        WHERE N.idContrato = @idContrato
              AND PTC.idContrato = @idContrato
            AND idFecha = @Fecha
        GROUP BY idFecha
        ORDER BY idFecha ASC;


        SELECT SUM(GastoGas) GasReal,
               s.Suma Proyeccion,
               ((SUM(GastoGas) / s.Suma) - 1) AS variacion
        FROM PR_ProdDiariaPozo_Previo prPre
            JOIN Pr_pozo pr
                ON prPre.Pozo = pr.id
            JOIN CO_PuntosdeEntregaContrato PTC
                ON pr.puntoEntregaId = PTC.PuntoEntregaID
            JOIN #SumaNominacion s
                ON s.idFecha = Fecha
        WHERE PTC.idContrato = @idContrato
              AND PTC.Activo = 1
              AND idFecha =@Fecha
        GROUP BY idFecha,
                 s.Suma;
    END;
    ELSE IF (@idHidrocarburo = 2) ---------------------------ACEITE
    BEGIN
        INSERT INTO #SumaNominacion
        (
            Suma,
            idFecha
        )
        SELECT SUM(VolumenProgramado),
               idFecha
        FROM CO_NominacionVolumen N
            JOIN CO_PuntosdeEntregaContrato PTC
                ON N.puntoEntregaId = PTC.PuntoEntregaID
                   AND N.idProductoNominacion = 1001
        WHERE N.idContrato = @idContrato
              AND PTC.idContrato = @idContrato
              AND idFecha =@Fecha
        GROUP BY idFecha
        ORDER BY idFecha ASC;

        SELECT SUM(ProdAceiteNeto) PetReal,
               s.Suma Proyeccion,
               ((SUM(ProdAceiteNeto) / s.Suma) - 1) AS variacion
        FROM PR_ProdDiariaPozo_Previo prPre
            JOIN Pr_pozo pr
                ON prPre.Pozo = pr.id
            JOIN CO_PuntosdeEntregaContrato PTC
                ON pr.puntoEntregaId = PTC.PuntoEntregaID
            JOIN #SumaNominacion s
                ON s.idFecha = Fecha
        WHERE PTC.idContrato = @idContrato
              AND PTC.Activo = 1
              AND idFecha =@Fecha
        GROUP BY idFecha,
                 s.Suma;
    END;
END;