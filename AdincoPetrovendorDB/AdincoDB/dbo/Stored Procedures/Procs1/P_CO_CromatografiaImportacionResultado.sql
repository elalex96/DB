IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'P_CO_CromatografiaImportacionResultado'
)
    DROP PROCEDURE P_CO_CromatografiaImportacionResultado;
GO

--Modificado por: Daniel Moreno
--Modificado El: 05/05/2022
--Descripción: Se agregan campos de temperatura periodos para que se consideren en el calculo de precio
--=======================================
--Modificado por: Reyna Olvera
--Modificado El: 14/12/2022
--Descripción: Se agregan campos de volumnenes de estado y contratista
--========================================
CREATE PROCEDURE [dbo].[P_CO_CromatografiaImportacionResultado] 
	@pIdsCromatografia VARCHAR(100)
AS
BEGIN
    ----------------------------------------------------------------
    --Modificado por: Reyna Olvera
    --Fecha 20180817
    --Comentarios: para que muestre el poder calorifico en el grid
    ----------------------------------------------------------------
    SET NOCOUNT ON;

    SELECT id = splitdata
    INTO #tmpCromatogarfias
    FROM [dbo].[fnSplitString](@pIdsCromatografia, ',')
    GROUP BY splitdata;

    SELECT Contrato = co.NumeroContrato,
           AreaContractual = ac.Descripcion,
           PuntoEntrega = pe.Nombre,
           Anio = c.Anio,
           Mes = CASE
                     WHEN c.Mes = 1 THEN
                         'Enero'
                     WHEN c.Mes = 2 THEN
                         'Febrero'
                     WHEN c.Mes = 3 THEN
                         'Marzo'
                     WHEN c.Mes = 4 THEN
                         'Abril'
                     WHEN c.Mes = 5 THEN
                         'Mayo'
                     WHEN c.Mes = 6 THEN
                         'Junio'
                     WHEN c.Mes = 7 THEN
                         'Julio'
                     WHEN c.Mes = 8 THEN
                         'Agosto'
                     WHEN c.Mes = 9 THEN
                         'Septiembre'
                     WHEN c.Mes = 10 THEN
                         'Octubre'
                     WHEN c.Mes = 11 THEN
                         'Noviembre'
                     WHEN c.Mes = 12 THEN
                         'Diciembre'
                 END,
           C1,
           C2,
           C3,
           nC4,
           lC4,
           nC5,
           lC5,
           C6_plus,
           C7 = ISNULL(C7, 0),
           C8 = ISNULL(C8, 0),
           C9 = ISNULL(C9, 0),
           C10 = ISNULL(C10, 0),
           MOL_CO2,
           MOL_N2,
           MOL_h2S,
           cv.GradosAPI,
           AguaSedimento,
           ViscosidadSSU,
           SalLBS_1000BLS,
           Azufre,
           PresionEntrega,
           PrecioPetroleo,
           PrecioCondensado,
           PrecioGas,
           PoderCalorifico,
           PoderCalorificoGas,
           Mensaje = CASE
                         WHEN cv.ModificadoPor > 0 THEN
                             'Valores Actualizados'
                         ELSE
                             'Valores Insertados'
                     END,
           FechaUltimoCambio = CASE
                                   WHEN cv.ModificadoEl IS NOT NULL THEN
                                       cv.ModificadoEl
                                   ELSE
                                       cv.CreadoEl
                               END,
           c.CreadoEl,
           cv.PrecioUnitarioCondensadoDLS,
           CASE
               WHEN ISNULL(PMS.VolumenProgramado, 0) = 0 THEN
                   0
               ELSE
                   PrecioPetroleo / PMS.VolumenProgramado
           END AS PrecioUnitarioDLS,
           CASE
               WHEN ISNULL(PMSG.VolumenProgramado, 0) = 0 THEN
                   0
               ELSE
                   cv.PrecioGas / PMSG.VolumenProgramado / 1000
           END AS PrecioUnitarioGas,
           cv.H2O,
           cv.O2,
           cv.TemperaturaPrecioPetroleo,
           cv.TemperaturaPrecioCondensado,
           ISNULL(PMS.VolumenContratista, 0) AS VolumenContratistaPetroleo,
           ISNULL(PMS.VolumenEstado, 0) AS VolumenEstadoPetroleo,
           ISNULL(PMC.VolumenContratista, 0) AS VolumenContratistaCondensado,
           ISNULL(PMC.VolumenEstado, 0) AS VolumenEstadoCondensado,
           c.IdArchivoGas AS IdArchivoGas,
		   c.IdArchivoPetroleo AS IdArchivoPetroleo
    FROM CO_Cromatografia c (NOLOCK)
        INNER JOIN CO_CromatografiaValores cv
            ON c.IdCromatografia = cv.IdCromatografia 
        INNER JOIN CO_Contrato co (NOLOCK)
            ON c.IdContrato = co.IdContrato
        INNER JOIN CO_AreaContractual ac (NOLOCK)
            ON co.IdAreaContractual = ac.IdAreaContractual 
        INNER JOIN [dbo].[CO_PuntosdeEntregaContrato] pec (NOLOCK)
            ON cv.IdPuntoEntregaContrato = pec.[PuntoEntregaContratoID]
        INNER JOIN [dbo].[CO_PuntosdeEntrega] pe (NOLOCK)
            ON pec.PuntoEntregaID = pe.PuntoEntregaID 
        INNER JOIN #tmpCromatogarfias tmp 
            ON c.IdCromatografia = tmp.id 
        LEFT JOIN PR_ProduccionMensualSipac PMS (NOLOCK)
            ON c.IdContrato = PMS.idContrato
               AND pec.PuntoEntregaID = PMS.PuntoEntregaID
               AND DATEFROMPARTS(c.Anio, c.Mes, 1) = PMS.idFecha
               AND PMS.idHidrocarburo = 1001
        LEFT JOIN PR_ProduccionMensualSipac PMSG (NOLOCK)
            ON c.IdContrato = PMSG.idContrato
               AND pec.PuntoEntregaID = PMSG.PuntoEntregaID
               AND DATEFROMPARTS(c.Anio, c.Mes, 1) = PMSG.idFecha
               AND PMSG.idHidrocarburo = 1000
        LEFT JOIN PR_ProduccionMensualSipac PMC (NOLOCK)
            ON c.IdContrato = PMC.idContrato
               AND pec.PuntoEntregaID = PMC.PuntoEntregaID
               AND DATEFROMPARTS(c.Anio, c.Mes, 1) = PMC.idFecha
               AND PMC.idHidrocarburo = 1002       
END;