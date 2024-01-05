IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_INS_CO_GuardadoDeCargaDePresupuesto'
    )
    DROP PROCEDURE USP_INS_CO_GuardadoDeCargaDePresupuesto
GO
CREATE PROCEDURE USP_INS_CO_GuardadoDeCargaDePresupuesto
    @UsuarioId INT,
    @ContratoId INT,
    @IdArchivoAWS INT
AS
BEGIN
DECLARE @ErrorMessage VARCHAR(4000);
    BEGIN TRY
        BEGIN TRAN
        SET NOCOUNT ON;

CREATE TABLE #Meses
    (
        Numero      int,
        FechaInicio DATE NULL,
        FechaFin    DATE NULL
    );
CREATE TABLE #LineasPresupuestoMesInformacion
    (
        Id                               INT          IDENTITY(1, 1),
        NumeroDeMes                      INT,
        FechaInicio                      DATE,
        FechaFin                         DATE,
        IdBitacoraPresupuestoDetalle     INT,
        IdCarga                          INT,
        IdDetalle                        INT,
        IdActividadPetrolera             VARCHAR(8000),
        ActividadPetrolera               VARCHAR(8000),
        IdActividadPetroleraTabla        INT          NULL,
        IdSubactividadPetrolera          VARCHAR(8000),
        SubactividadPetrolera            VARCHAR(8000),
        IdSubactividadPetroleraTabla     INT          NULL,
        IdTarea                          VARCHAR(8000),
        Tarea                            VARCHAR(8000),
        IdTareaTabla                     INT          NULL,
        Servicio                         VARCHAR(8000),
        IdServicioTabla                  INT          NULL,
        Pozo_Instalacion                 VARCHAR(8000),
        IdInstalacionTabla               INT          NULL,
        CPXOPX                           VARCHAR(8000),
        CAPEX                            BIT,
        ManodeObraContNac                FLOAT        NULL,
        ManodeObraExtranjero             FLOAT        NULL,
        BienesContNac          FLOAT        NULL,
        BienesExtranjero       FLOAT        NULL,
        ServiciosContNac       FLOAT        NULL,
        ServiciosExtranjero    FLOAT        NULL,
        CapacitaciónContNac    FLOAT        NULL,
        CapacitaciónExtranjero FLOAT        NULL,
        TransferenciadeTecnología        FLOAT        NULL,
        Infraestructura                  FLOAT        NULL,
        Monto                            FLOAT        NULL
    );
DECLARE
    @IdCarga                 INT          = 0,
    @AdjuntarClaveSubtarea   INT          = 0,
    @IdContratoSeleccionado  INT          = 0,
    @IdPeriodoContrato       INT          = 0,
    @NombrePeriodo           VARCHAR(8000),
    @Inicio                  DATE,
    @Fin                     DATE,
    @IdProgramaActividad     INT          = 0,
    @NombreProgramaActividad VARCHAR(8000),
    @IdPresupuesto           INT          = 0,
    @NombrePresupuesto       VARCHAR(8000),
    @IdTipoProgramaActividad INT,
    @IdAnioContractual       INT,
    @Version                 INT          = 1,
    @Comentario              VARCHAR(500) = 'Carga por pantalla',
    @IdAreaContractual       INT, @IdTipoServicio INT =10,@IdActividad INT = 6,@IdSubactividad INT=10045,@IdActvidadHidrocarburo	INT	= 10000 , @IdArea INT = 10011;

INSERT INTO #Meses
    (
        Numero
    )
            SELECT
                1;
INSERT INTO #Meses
    (
        Numero
    )
            SELECT
                2;
INSERT INTO #Meses
    (
        Numero
    )
            SELECT
                3;
INSERT INTO #Meses
    (
        Numero
    )
            SELECT
                4;
INSERT INTO #Meses
    (
        Numero
    )
            SELECT
                5;
INSERT INTO #Meses
    (
        Numero
    )
            SELECT
                6;
INSERT INTO #Meses
    (
        Numero
    )
            SELECT
                7;
INSERT INTO #Meses
    (
        Numero
    )
            SELECT
                8;
INSERT INTO #Meses
    (
        Numero
    )
            SELECT
                9;
INSERT INTO #Meses
    (
        Numero
    )
            SELECT
                10;
INSERT INTO #Meses
    (
        Numero
    )
            SELECT
                11;
INSERT INTO #Meses
    (
        Numero
    )
            SELECT
                12;
INSERT INTO #Meses
    (
        Numero
    )
            SELECT
                13;
INSERT INTO #Meses
    (
        Numero
    )
            SELECT
                14;
INSERT INTO #Meses
    (
        Numero
    )
            SELECT
                15;
INSERT INTO #Meses
    (
        Numero
    )
            SELECT
                16;
INSERT INTO #Meses
    (
        Numero
    )
            SELECT
                17;
INSERT INTO #Meses
    (
        Numero
    )
            SELECT
                18;
INSERT INTO #Meses
    (
        Numero
    )
            SELECT
                19;
INSERT INTO #Meses
    (
        Numero
    )
            SELECT
                20;
INSERT INTO #Meses
    (
        Numero
    )
            SELECT
                21;
INSERT INTO #Meses
    (
        Numero
    )
            SELECT
                22;
INSERT INTO #Meses
    (
        Numero
    )
            SELECT
                23;
INSERT INTO #Meses
    (
        Numero
    )
            SELECT
                24;
Select
    @IdCarga                 = IdCarga,
    @AdjuntarClaveSubtarea   = chkAdjuntaClaveSubTarea,
    @IdContratoSeleccionado  = IdContrato,
    @NombrePeriodo           = Periodo,
    @Inicio                  = Inicio,
    @Fin                     = Fin,
    @NombreProgramaActividad = Programa,
    @IdTipoProgramaActividad = IdTipoProgramaActividad,
    @NombrePresupuesto       = Presupuesto
FROM
    CO_BitacoraPresupuesto
where
    IdArchivoAWS = @IdArchivoAWS;
SELECT TOP 1
    @IdAreaContractual = IdAreaContractual
FROM
    CO_Contrato (NOLOCK)
WHERE
    IdContrato = @IdContratoSeleccionado;
UPDATE
    #Meses
SET
    FechaInicio = DATEFROMPARTS(year(@Inicio), month(@Inicio), 1)
UPDATE
    #Meses
SET
    FechaFin = DATEFROMPARTS(year(@Inicio), month(@Inicio), DAY(EOMONTH(@Inicio)))
WHERE
    Numero = 1
UPDATE
    #Meses
SET
    FechaInicio = (DATEADD(MONTH, (Numero - 1), FechaInicio))
FROM
    #Meses
WHERE
    Numero > 1
UPDATE
    #Meses
SET
    FechaFin = DATEFROMPARTS(year(FechaInicio), month(FechaInicio), DAY(EOMONTH(FechaInicio)))
FROM
    #Meses
WHERE
    Numero > 1
INSERT INTO #LineasPresupuestoMesInformacion
    (
        NumeroDeMes,
        FechaInicio,
        FechaFin,
        IdBitacoraPresupuestoDetalle,
        IdCarga,
        IdDetalle,
        IdActividadPetrolera,
        ActividadPetrolera,
        IdSubactividadPetrolera,
        SubactividadPetrolera,
        IdTarea,
        Tarea,
        Servicio,
        Pozo_Instalacion,
        CPXOPX,
        CAPEX
    )
            SELECT
                #Meses.Numero,
                #Meses.FechaInicio,
                #Meses.FechaFin,
                CO_BitacoraPresupuestoDetalle.Id,
                CO_BitacoraPresupuestoDetalle.IdCarga,
                CO_BitacoraPresupuestoDetalle.IdDetalle,
                CO_BitacoraPresupuestoDetalle.IdActividadPetrolera,
                CO_BitacoraPresupuestoDetalle.ActividadPetrolera,
                CO_BitacoraPresupuestoDetalle.IdSubactividadPetrolera,
                CO_BitacoraPresupuestoDetalle.SubactividadPetrolera,
                CO_BitacoraPresupuestoDetalle.IdTarea,
                CO_BitacoraPresupuestoDetalle.Tarea,
                CASE
                    WHEN @AdjuntarClaveSubtarea = 1
                        THEN LTRIM(RTRIM(CONCAT(
                                                   CO_BitacoraPresupuestoDetalle.IdSubtarea, '-',
                                                   CO_BitacoraPresupuestoDetalle.Subtarea_Servicio
                                               )
                                        )
                                  )
                    ELSE
                        Subtarea_Servicio
                END                          AS SERVICIO,
                CO_BitacoraPresupuestoDetalle.Pozo_Instalacion,
                CASE
                    WHEN REPLACE(UPPER(RTRIM(LTRIM(CO_BitacoraPresupuestoDetalle.CAPEX_OPEX))), ' ', '') = 'GASTOOPERATIVO'
                        THEN 'OPEX'
                    WHEN REPLACE(UPPER(RTRIM(LTRIM(CO_BitacoraPresupuestoDetalle.CAPEX_OPEX))), ' ', '') = 'INVERSIÓN'
                        THEN 'CAPEX'
                    ELSE
                        'OPEX'
                END,
                CASE
                    WHEN REPLACE(UPPER(RTRIM(LTRIM(CO_BitacoraPresupuestoDetalle.CAPEX_OPEX))), ' ', '') = 'GASTOOPERATIVO'
                        THEN 0
                    WHEN REPLACE(UPPER(RTRIM(LTRIM(CO_BitacoraPresupuestoDetalle.CAPEX_OPEX))), ' ', '') = 'INVERSIÓN'
                        THEN 1
                    ELSE
                        0
                END
            FROM
                CO_BitacoraPresupuestoDetalle
                CROSS JOIN #Meses
            WHERE
                CO_BitacoraPresupuestoDetalle.IdCarga = @IdCarga
UPDATE
    #LineasPresupuestoMesInformacion
SET
    #LineasPresupuestoMesInformacion.IdInstalacionTabla = CO_Instalacion.IdInstalacion
from
    #LineasPresupuestoMesInformacion
    JOIN
        CO_Instalacion
            ON LTRIM(RTRIM(#LineasPresupuestoMesInformacion.Pozo_Instalacion)) = LTRIM(RTRIM(ISNULL(
                                                                                                       CO_Instalacion.NombreInstalacion,
                                                                                                       ''
                                                                                                   )
                                                                                            )
                                                                                      )
WHERE
    CO_Instalacion.IdAreaContractual = @IdAreaContractual
    AND ISNULL(CO_Instalacion.Activo, 0) = 1;

UPDATE
    #LineasPresupuestoMesInformacion
SET
    #LineasPresupuestoMesInformacion.IdTareaTabla = CO_TareaPetrolera.IdTareaPetrolera
from
    #LineasPresupuestoMesInformacion
    JOIN
        CO_TareaPetrolera
            ON LTRIM(RTRIM(#LineasPresupuestoMesInformacion.IdTarea)) = LTRIM(RTRIM(ISNULL(
                                                                                              CO_TareaPetrolera.ID_TAREA,
                                                                                              ''
                                                                                          )
                                                                                   )
                                                                             );

UPDATE
    #LineasPresupuestoMesInformacion
SET
    #LineasPresupuestoMesInformacion.IdActividadPetroleraTabla = CO_ActividadPetroleraCNH.IdActividadPetrolera
from
    #LineasPresupuestoMesInformacion
    JOIN
        CO_ActividadPetroleraCNH
            ON LTRIM(RTRIM(#LineasPresupuestoMesInformacion.IdActividadPetrolera)) = LTRIM(RTRIM(ISNULL(
                                                                                                           CO_ActividadPetroleraCNH.id_Actividad,
                                                                                                           ''
                                                                                                       )
                                                                                                )
                                                                                          );
UPDATE
    #LineasPresupuestoMesInformacion
SET
    #LineasPresupuestoMesInformacion.IdSubactividadPetroleraTabla = CO_SubactividadPetrolera.IdSubactividadPetrolera
from
    #LineasPresupuestoMesInformacion
    JOIN
        CO_SubactividadPetrolera
            ON LTRIM(RTRIM(#LineasPresupuestoMesInformacion.IdSubactividadPetrolera)) = LTRIM(RTRIM(ISNULL(
                                                                                                              CO_SubactividadPetrolera.[id_Sub-actividad],
                                                                                                              ''
                                                                                                          )
                                                                                                   )
                                                                                             );

UPDATE
    #LineasPresupuestoMesInformacion
SET
    #LineasPresupuestoMesInformacion.IdServicioTabla = CO_Servicio.IdServicio
FROM
    #LineasPresupuestoMesInformacion
    JOIN
        CO_Servicio
            ON #LineasPresupuestoMesInformacion.Servicio = LTRIM(RTRIM(ISNULL(CO_Servicio.NombreServicio, '')))
WHERE
    CO_Servicio.IdContrato = @IdContratoSeleccionado
    AND ISNULL(CO_Servicio.Activo, 0) = 1;

-- INSERCIÓN DE MONTOS POR MESES
UPDATE
    #LineasPresupuestoMesInformacion
SET
    #LineasPresupuestoMesInformacion.ManodeObraContNac = ISNULL(PA_17, 0),
    #LineasPresupuestoMesInformacion.ManodeObraExtranjero = ISNULL(PA_18, 0),
    #LineasPresupuestoMesInformacion.BienesContNac = ISNULL(PA_19, 0),
    #LineasPresupuestoMesInformacion.BienesExtranjero = ISNULL(PA_20, 0),
    #LineasPresupuestoMesInformacion.ServiciosContNac = ISNULL(PA_21, 0),
    #LineasPresupuestoMesInformacion.ServiciosExtranjero = ISNULL(PA_22, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónContNac = ISNULL(PA_23, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónExtranjero = ISNULL(PA_24, 0),
    #LineasPresupuestoMesInformacion.TransferenciadeTecnología = ISNULL(PA_25, 0),
    #LineasPresupuestoMesInformacion.Infraestructura = ISNULL(PA_26, 0)
FROM
    #LineasPresupuestoMesInformacion
    JOIN
        CO_BitacoraPresupuestoDetalle
            ON #LineasPresupuestoMesInformacion.IdBitacoraPresupuestoDetalle = CO_BitacoraPresupuestoDetalle.Id
               AND NumeroDeMes = 1
               AND (
                       ISNULL(PA_17, 0) > 0
                       OR ISNULL(PA_18, 0) > 0
                       OR ISNULL(PA_19, 0) > 0
                       OR ISNULL(PA_20, 0) > 0
                       OR ISNULL(PA_21, 0) > 0
                       OR ISNULL(PA_22, 0) > 0
                       OR ISNULL(PA_23, 0) > 0
                       OR ISNULL(PA_24, 0) > 0
                       OR ISNULL(PA_25, 0) > 0
                       OR ISNULL(PA_26, 0) > 0
                   )
UPDATE
    #LineasPresupuestoMesInformacion
SET
    #LineasPresupuestoMesInformacion.ManodeObraContNac = ISNULL(PA_27, 0),
    #LineasPresupuestoMesInformacion.ManodeObraExtranjero = ISNULL(PA_28, 0),
    #LineasPresupuestoMesInformacion.BienesContNac = ISNULL(PA_29, 0),
    #LineasPresupuestoMesInformacion.BienesExtranjero = ISNULL(PA_30, 0),
    #LineasPresupuestoMesInformacion.ServiciosContNac = ISNULL(PA_31, 0),
    #LineasPresupuestoMesInformacion.ServiciosExtranjero = ISNULL(PA_32, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónContNac = ISNULL(PA_33, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónExtranjero = ISNULL(PA_34, 0),
    #LineasPresupuestoMesInformacion.TransferenciadeTecnología = ISNULL(PA_35, 0),
    #LineasPresupuestoMesInformacion.Infraestructura = ISNULL(PA_36, 0)
FROM
    #LineasPresupuestoMesInformacion
    JOIN
        CO_BitacoraPresupuestoDetalle
            ON #LineasPresupuestoMesInformacion.IdBitacoraPresupuestoDetalle = CO_BitacoraPresupuestoDetalle.Id
               AND NumeroDeMes = 2
               AND (
                       ISNULL(PA_27, 0) > 0
                       OR ISNULL(PA_28, 0) > 0
                       OR ISNULL(PA_29, 0) > 0
                       OR ISNULL(PA_30, 0) > 0
                       OR ISNULL(PA_31, 0) > 0
                       OR ISNULL(PA_32, 0) > 0
                       OR ISNULL(PA_33, 0) > 0
                       OR ISNULL(PA_34, 0) > 0
                       OR ISNULL(PA_35, 0) > 0
                       OR ISNULL(PA_36, 0) > 0
                   );
UPDATE
    #LineasPresupuestoMesInformacion
SET
    #LineasPresupuestoMesInformacion.ManodeObraContNac = ISNULL(PA_37, 0),
    #LineasPresupuestoMesInformacion.ManodeObraExtranjero = ISNULL(PA_38, 0),
    #LineasPresupuestoMesInformacion.BienesContNac = ISNULL(PA_39, 0),
    #LineasPresupuestoMesInformacion.BienesExtranjero = ISNULL(PA_40, 0),
    #LineasPresupuestoMesInformacion.ServiciosContNac = ISNULL(PA_41, 0),
    #LineasPresupuestoMesInformacion.ServiciosExtranjero = ISNULL(PA_42, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónContNac = ISNULL(PA_43, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónExtranjero = ISNULL(PA_44, 0),
    #LineasPresupuestoMesInformacion.TransferenciadeTecnología = ISNULL(PA_45, 0),
    #LineasPresupuestoMesInformacion.Infraestructura = ISNULL(PA_46, 0)
FROM
    #LineasPresupuestoMesInformacion
    JOIN
        CO_BitacoraPresupuestoDetalle
            ON #LineasPresupuestoMesInformacion.IdBitacoraPresupuestoDetalle = CO_BitacoraPresupuestoDetalle.Id
               AND NumeroDeMes = 3
               AND (
                       ISNULL(PA_37, 0) > 0
                       OR ISNULL(PA_38, 0) > 0
                       OR ISNULL(PA_39, 0) > 0
                       OR ISNULL(PA_40, 0) > 0
                       OR ISNULL(PA_41, 0) > 0
                       OR ISNULL(PA_42, 0) > 0
                       OR ISNULL(PA_43, 0) > 0
                       OR ISNULL(PA_44, 0) > 0
                       OR ISNULL(PA_45, 0) > 0
                       OR ISNULL(PA_46, 0) > 0
                   );
UPDATE
    #LineasPresupuestoMesInformacion
SET
    #LineasPresupuestoMesInformacion.ManodeObraContNac = ISNULL(PA_47, 0),
    #LineasPresupuestoMesInformacion.ManodeObraExtranjero = ISNULL(PA_48, 0),
    #LineasPresupuestoMesInformacion.BienesContNac = ISNULL(PA_49, 0),
    #LineasPresupuestoMesInformacion.BienesExtranjero = ISNULL(PA_50, 0),
    #LineasPresupuestoMesInformacion.ServiciosContNac = ISNULL(PA_51, 0),
    #LineasPresupuestoMesInformacion.ServiciosExtranjero = ISNULL(PA_52, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónContNac = ISNULL(PA_53, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónExtranjero = ISNULL(PA_54, 0),
    #LineasPresupuestoMesInformacion.TransferenciadeTecnología = ISNULL(PA_55, 0),
    #LineasPresupuestoMesInformacion.Infraestructura = ISNULL(PA_56, 0)
FROM
    #LineasPresupuestoMesInformacion
    JOIN
        CO_BitacoraPresupuestoDetalle
            ON #LineasPresupuestoMesInformacion.IdBitacoraPresupuestoDetalle = CO_BitacoraPresupuestoDetalle.Id
               AND NumeroDeMes = 4
               AND (
                       ISNULL(PA_47, 0) > 0
                       OR ISNULL(PA_48, 0) > 0
                       OR ISNULL(PA_49, 0) > 0
                       OR ISNULL(PA_50, 0) > 0
                       OR ISNULL(PA_51, 0) > 0
                       OR ISNULL(PA_52, 0) > 0
                       OR ISNULL(PA_53, 0) > 0
                       OR ISNULL(PA_54, 0) > 0
                       OR ISNULL(PA_55, 0) > 0
                       OR ISNULL(PA_56, 0) > 0
                   );
UPDATE
    #LineasPresupuestoMesInformacion
SET
    #LineasPresupuestoMesInformacion.ManodeObraContNac = ISNULL(PA_57, 0),
    #LineasPresupuestoMesInformacion.ManodeObraExtranjero = ISNULL(PA_58, 0),
    #LineasPresupuestoMesInformacion.BienesContNac = ISNULL(PA_59, 0),
    #LineasPresupuestoMesInformacion.BienesExtranjero = ISNULL(PA_60, 0),
    #LineasPresupuestoMesInformacion.ServiciosContNac = ISNULL(PA_61, 0),
    #LineasPresupuestoMesInformacion.ServiciosExtranjero = ISNULL(PA_62, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónContNac = ISNULL(PA_63, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónExtranjero = ISNULL(PA_64, 0),
    #LineasPresupuestoMesInformacion.TransferenciadeTecnología = ISNULL(PA_65, 0),
    #LineasPresupuestoMesInformacion.Infraestructura = ISNULL(PA_66, 0)
FROM
    #LineasPresupuestoMesInformacion
    JOIN
        CO_BitacoraPresupuestoDetalle
            ON #LineasPresupuestoMesInformacion.IdBitacoraPresupuestoDetalle = CO_BitacoraPresupuestoDetalle.Id
               AND NumeroDeMes = 5
               AND (
                       ISNULL(PA_57, 0) > 0
                       OR ISNULL(PA_58, 0) > 0
                       OR ISNULL(PA_59, 0) > 0
                       OR ISNULL(PA_60, 0) > 0
                       OR ISNULL(PA_61, 0) > 0
                       OR ISNULL(PA_62, 0) > 0
                       OR ISNULL(PA_63, 0) > 0
                       OR ISNULL(PA_64, 0) > 0
                       OR ISNULL(PA_65, 0) > 0
                       OR ISNULL(PA_66, 0) > 0
                   );
UPDATE
    #LineasPresupuestoMesInformacion
SET
    #LineasPresupuestoMesInformacion.ManodeObraContNac = ISNULL(PA_67, 0),
    #LineasPresupuestoMesInformacion.ManodeObraExtranjero = ISNULL(PA_68, 0),
    #LineasPresupuestoMesInformacion.BienesContNac = ISNULL(PA_69, 0),
    #LineasPresupuestoMesInformacion.BienesExtranjero = ISNULL(PA_70, 0),
    #LineasPresupuestoMesInformacion.ServiciosContNac = ISNULL(PA_71, 0),
    #LineasPresupuestoMesInformacion.ServiciosExtranjero = ISNULL(PA_72, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónContNac = ISNULL(PA_73, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónExtranjero = ISNULL(PA_74, 0),
    #LineasPresupuestoMesInformacion.TransferenciadeTecnología = ISNULL(PA_75, 0),
    #LineasPresupuestoMesInformacion.Infraestructura = ISNULL(PA_76, 0)
FROM
    #LineasPresupuestoMesInformacion
    JOIN
        CO_BitacoraPresupuestoDetalle
            ON #LineasPresupuestoMesInformacion.IdBitacoraPresupuestoDetalle = CO_BitacoraPresupuestoDetalle.Id
               AND NumeroDeMes = 6
               AND (
                       ISNULL(PA_67, 0) > 0
                       OR ISNULL(PA_68, 0) > 0
                       OR ISNULL(PA_69, 0) > 0
                       OR ISNULL(PA_70, 0) > 0
                       OR ISNULL(PA_71, 0) > 0
                       OR ISNULL(PA_72, 0) > 0
                       OR ISNULL(PA_73, 0) > 0
                       OR ISNULL(PA_74, 0) > 0
                       OR ISNULL(PA_75, 0) > 0
                       OR ISNULL(PA_76, 0) > 0
                   );
UPDATE
    #LineasPresupuestoMesInformacion
SET
    #LineasPresupuestoMesInformacion.ManodeObraContNac = ISNULL(PA_77, 0),
    #LineasPresupuestoMesInformacion.ManodeObraExtranjero = ISNULL(PA_78, 0),
    #LineasPresupuestoMesInformacion.BienesContNac = ISNULL(PA_79, 0),
    #LineasPresupuestoMesInformacion.BienesExtranjero = ISNULL(PA_80, 0),
    #LineasPresupuestoMesInformacion.ServiciosContNac = ISNULL(PA_81, 0),
    #LineasPresupuestoMesInformacion.ServiciosExtranjero = ISNULL(PA_82, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónContNac = ISNULL(PA_83, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónExtranjero = ISNULL(PA_84, 0),
    #LineasPresupuestoMesInformacion.TransferenciadeTecnología = ISNULL(PA_85, 0),
    #LineasPresupuestoMesInformacion.Infraestructura = ISNULL(PA_86, 0)
FROM
    #LineasPresupuestoMesInformacion
    JOIN
        CO_BitacoraPresupuestoDetalle
            ON #LineasPresupuestoMesInformacion.IdBitacoraPresupuestoDetalle = CO_BitacoraPresupuestoDetalle.Id
               AND NumeroDeMes = 7
               AND (
                       ISNULL(PA_77, 0) > 0
                       OR ISNULL(PA_78, 0) > 0
                       OR ISNULL(PA_79, 0) > 0
                       OR ISNULL(PA_80, 0) > 0
                       OR ISNULL(PA_81, 0) > 0
                       OR ISNULL(PA_82, 0) > 0
                       OR ISNULL(PA_83, 0) > 0
                       OR ISNULL(PA_84, 0) > 0
                       OR ISNULL(PA_85, 0) > 0
                       OR ISNULL(PA_86, 0) > 0
                   );
UPDATE
    #LineasPresupuestoMesInformacion
SET
    #LineasPresupuestoMesInformacion.ManodeObraContNac = ISNULL(PA_87, 0),
    #LineasPresupuestoMesInformacion.ManodeObraExtranjero = ISNULL(PA_88, 0),
    #LineasPresupuestoMesInformacion.BienesContNac = ISNULL(PA_89, 0),
    #LineasPresupuestoMesInformacion.BienesExtranjero = ISNULL(PA_90, 0),
    #LineasPresupuestoMesInformacion.ServiciosContNac = ISNULL(PA_91, 0),
    #LineasPresupuestoMesInformacion.ServiciosExtranjero = ISNULL(PA_92, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónContNac = ISNULL(PA_93, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónExtranjero = ISNULL(PA_94, 0),
    #LineasPresupuestoMesInformacion.TransferenciadeTecnología = ISNULL(PA_95, 0),
    #LineasPresupuestoMesInformacion.Infraestructura = ISNULL(PA_96, 0)
FROM
    #LineasPresupuestoMesInformacion
    JOIN
        CO_BitacoraPresupuestoDetalle
            ON #LineasPresupuestoMesInformacion.IdBitacoraPresupuestoDetalle = CO_BitacoraPresupuestoDetalle.Id
               AND NumeroDeMes = 8
               AND (
                       ISNULL(PA_87, 0) > 0
                       OR ISNULL(PA_88, 0) > 0
                       OR ISNULL(PA_89, 0) > 0
                       OR ISNULL(PA_90, 0) > 0
                       OR ISNULL(PA_91, 0) > 0
                       OR ISNULL(PA_92, 0) > 0
                       OR ISNULL(PA_93, 0) > 0
                       OR ISNULL(PA_94, 0) > 0
                       OR ISNULL(PA_95, 0) > 0
                       OR ISNULL(PA_96, 0) > 0
                   );
UPDATE
    #LineasPresupuestoMesInformacion
SET
    #LineasPresupuestoMesInformacion.ManodeObraContNac = ISNULL(PA_97, 0),
    #LineasPresupuestoMesInformacion.ManodeObraExtranjero = ISNULL(PA_98, 0),
    #LineasPresupuestoMesInformacion.BienesContNac = ISNULL(PA_99, 0),
    #LineasPresupuestoMesInformacion.BienesExtranjero = ISNULL(PA_100, 0),
    #LineasPresupuestoMesInformacion.ServiciosContNac = ISNULL(PA_101, 0),
    #LineasPresupuestoMesInformacion.ServiciosExtranjero = ISNULL(PA_102, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónContNac = ISNULL(PA_103, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónExtranjero = ISNULL(PA_104, 0),
    #LineasPresupuestoMesInformacion.TransferenciadeTecnología = ISNULL(PA_105, 0),
    #LineasPresupuestoMesInformacion.Infraestructura = ISNULL(PA_106, 0)
FROM
    #LineasPresupuestoMesInformacion
    JOIN
        CO_BitacoraPresupuestoDetalle
            ON #LineasPresupuestoMesInformacion.IdBitacoraPresupuestoDetalle = CO_BitacoraPresupuestoDetalle.Id
               AND NumeroDeMes = 9
               AND (
                       ISNULL(PA_97, 0) > 0
                       OR ISNULL(PA_98, 0) > 0
                       OR ISNULL(PA_99, 0) > 0
                       OR ISNULL(PA_100, 0) > 0
                       OR ISNULL(PA_101, 0) > 0
                       OR ISNULL(PA_102, 0) > 0
                       OR ISNULL(PA_103, 0) > 0
                       OR ISNULL(PA_104, 0) > 0
                       OR ISNULL(PA_105, 0) > 0
                       OR ISNULL(PA_106, 0) > 0
                   );
UPDATE
    #LineasPresupuestoMesInformacion
SET
    #LineasPresupuestoMesInformacion.ManodeObraContNac = ISNULL(PA_107, 0),
    #LineasPresupuestoMesInformacion.ManodeObraExtranjero = ISNULL(PA_108, 0),
    #LineasPresupuestoMesInformacion.BienesContNac = ISNULL(PA_109, 0),
    #LineasPresupuestoMesInformacion.BienesExtranjero = ISNULL(PA_110, 0),
    #LineasPresupuestoMesInformacion.ServiciosContNac = ISNULL(PA_111, 0),
    #LineasPresupuestoMesInformacion.ServiciosExtranjero = ISNULL(PA_112, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónContNac = ISNULL(PA_113, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónExtranjero = ISNULL(PA_114, 0),
    #LineasPresupuestoMesInformacion.TransferenciadeTecnología = ISNULL(PA_115, 0),
    #LineasPresupuestoMesInformacion.Infraestructura = ISNULL(PA_116, 0)
FROM
    #LineasPresupuestoMesInformacion
    JOIN
        CO_BitacoraPresupuestoDetalle
            ON #LineasPresupuestoMesInformacion.IdBitacoraPresupuestoDetalle = CO_BitacoraPresupuestoDetalle.Id
               AND NumeroDeMes = 10
               AND (
                       ISNULL(PA_107, 0) > 0
                       OR ISNULL(PA_108, 0) > 0
                       OR ISNULL(PA_109, 0) > 0
                       OR ISNULL(PA_110, 0) > 0
                       OR ISNULL(PA_111, 0) > 0
                       OR ISNULL(PA_112, 0) > 0
                       OR ISNULL(PA_113, 0) > 0
                       OR ISNULL(PA_114, 0) > 0
                       OR ISNULL(PA_115, 0) > 0
                       OR ISNULL(PA_116, 0) > 0
                   );
UPDATE
    #LineasPresupuestoMesInformacion
SET
    #LineasPresupuestoMesInformacion.ManodeObraContNac = ISNULL(PA_117, 0),
    #LineasPresupuestoMesInformacion.ManodeObraExtranjero = ISNULL(PA_118, 0),
    #LineasPresupuestoMesInformacion.BienesContNac = ISNULL(PA_119, 0),
    #LineasPresupuestoMesInformacion.BienesExtranjero = ISNULL(PA_120, 0),
    #LineasPresupuestoMesInformacion.ServiciosContNac = ISNULL(PA_121, 0),
    #LineasPresupuestoMesInformacion.ServiciosExtranjero = ISNULL(PA_122, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónContNac = ISNULL(PA_123, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónExtranjero = ISNULL(PA_124, 0),
    #LineasPresupuestoMesInformacion.TransferenciadeTecnología = ISNULL(PA_125, 0),
    #LineasPresupuestoMesInformacion.Infraestructura = ISNULL(PA_126, 0)
FROM
    #LineasPresupuestoMesInformacion
    JOIN
        CO_BitacoraPresupuestoDetalle
            ON #LineasPresupuestoMesInformacion.IdBitacoraPresupuestoDetalle = CO_BitacoraPresupuestoDetalle.Id
               AND NumeroDeMes = 11
               AND (
                       ISNULL(PA_117, 0) > 0
                       OR ISNULL(PA_118, 0) > 0
                       OR ISNULL(PA_119, 0) > 0
                       OR ISNULL(PA_120, 0) > 0
                       OR ISNULL(PA_121, 0) > 0
                       OR ISNULL(PA_122, 0) > 0
                       OR ISNULL(PA_123, 0) > 0
                       OR ISNULL(PA_124, 0) > 0
                       OR ISNULL(PA_125, 0) > 0
                       OR ISNULL(PA_126, 0) > 0
                   );
UPDATE
    #LineasPresupuestoMesInformacion
SET
    #LineasPresupuestoMesInformacion.ManodeObraContNac = ISNULL(PA_127, 0),
    #LineasPresupuestoMesInformacion.ManodeObraExtranjero = ISNULL(PA_128, 0),
    #LineasPresupuestoMesInformacion.BienesContNac = ISNULL(PA_129, 0),
    #LineasPresupuestoMesInformacion.BienesExtranjero = ISNULL(PA_130, 0),
    #LineasPresupuestoMesInformacion.ServiciosContNac = ISNULL(PA_131, 0),
    #LineasPresupuestoMesInformacion.ServiciosExtranjero = ISNULL(PA_132, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónContNac = ISNULL(PA_133, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónExtranjero = ISNULL(PA_134, 0),
    #LineasPresupuestoMesInformacion.TransferenciadeTecnología = ISNULL(PA_135, 0),
    #LineasPresupuestoMesInformacion.Infraestructura = ISNULL(PA_136, 0)
FROM
    #LineasPresupuestoMesInformacion
    JOIN
        CO_BitacoraPresupuestoDetalle
            ON #LineasPresupuestoMesInformacion.IdBitacoraPresupuestoDetalle = CO_BitacoraPresupuestoDetalle.Id
               AND NumeroDeMes = 12
               AND (
                       ISNULL(PA_127, 0) > 0
                       OR ISNULL(PA_128, 0) > 0
                       OR ISNULL(PA_129, 0) > 0
                       OR ISNULL(PA_130, 0) > 0
                       OR ISNULL(PA_131, 0) > 0
                       OR ISNULL(PA_132, 0) > 0
                       OR ISNULL(PA_133, 0) > 0
                       OR ISNULL(PA_134, 0) > 0
                       OR ISNULL(PA_135, 0) > 0
                       OR ISNULL(PA_136, 0) > 0
                   );
UPDATE
    #LineasPresupuestoMesInformacion
SET
    #LineasPresupuestoMesInformacion.ManodeObraContNac = ISNULL(PA_137, 0),
    #LineasPresupuestoMesInformacion.ManodeObraExtranjero = ISNULL(PA_138, 0),
    #LineasPresupuestoMesInformacion.BienesContNac = ISNULL(PA_139, 0),
    #LineasPresupuestoMesInformacion.BienesExtranjero = ISNULL(PA_140, 0),
    #LineasPresupuestoMesInformacion.ServiciosContNac = ISNULL(PA_141, 0),
    #LineasPresupuestoMesInformacion.ServiciosExtranjero = ISNULL(PA_142, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónContNac = ISNULL(PA_143, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónExtranjero = ISNULL(PA_144, 0),
    #LineasPresupuestoMesInformacion.TransferenciadeTecnología = ISNULL(PA_145, 0),
    #LineasPresupuestoMesInformacion.Infraestructura = ISNULL(PA_146, 0)
FROM
    #LineasPresupuestoMesInformacion
    JOIN
        CO_BitacoraPresupuestoDetalle
            ON #LineasPresupuestoMesInformacion.IdBitacoraPresupuestoDetalle = CO_BitacoraPresupuestoDetalle.Id
               AND NumeroDeMes = 13
               AND (
                       ISNULL(PA_137, 0) > 0
                       OR ISNULL(PA_138, 0) > 0
                       OR ISNULL(PA_139, 0) > 0
                       OR ISNULL(PA_140, 0) > 0
                       OR ISNULL(PA_141, 0) > 0
                       OR ISNULL(PA_142, 0) > 0
                       OR ISNULL(PA_143, 0) > 0
                       OR ISNULL(PA_144, 0) > 0
                       OR ISNULL(PA_145, 0) > 0
                       OR ISNULL(PA_146, 0) > 0
                   );
UPDATE
    #LineasPresupuestoMesInformacion
SET
    #LineasPresupuestoMesInformacion.ManodeObraContNac = ISNULL(PA_147, 0),
    #LineasPresupuestoMesInformacion.ManodeObraExtranjero = ISNULL(PA_148, 0),
    #LineasPresupuestoMesInformacion.BienesContNac = ISNULL(PA_149, 0),
    #LineasPresupuestoMesInformacion.BienesExtranjero = ISNULL(PA_150, 0),
    #LineasPresupuestoMesInformacion.ServiciosContNac = ISNULL(PA_151, 0),
    #LineasPresupuestoMesInformacion.ServiciosExtranjero = ISNULL(PA_152, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónContNac = ISNULL(PA_153, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónExtranjero = ISNULL(PA_154, 0),
    #LineasPresupuestoMesInformacion.TransferenciadeTecnología = ISNULL(PA_155, 0),
    #LineasPresupuestoMesInformacion.Infraestructura = ISNULL(PA_156, 0)
FROM
    #LineasPresupuestoMesInformacion
    JOIN
        CO_BitacoraPresupuestoDetalle
            ON #LineasPresupuestoMesInformacion.IdBitacoraPresupuestoDetalle = CO_BitacoraPresupuestoDetalle.Id
               AND NumeroDeMes = 14
               AND (
                       ISNULL(PA_147, 0) > 0
                       OR ISNULL(PA_148, 0) > 0
                       OR ISNULL(PA_149, 0) > 0
                       OR ISNULL(PA_150, 0) > 0
                       OR ISNULL(PA_151, 0) > 0
                       OR ISNULL(PA_152, 0) > 0
                       OR ISNULL(PA_153, 0) > 0
                       OR ISNULL(PA_154, 0) > 0
                       OR ISNULL(PA_155, 0) > 0
                       OR ISNULL(PA_156, 0) > 0
                   );
UPDATE
    #LineasPresupuestoMesInformacion
SET
    #LineasPresupuestoMesInformacion.ManodeObraContNac = ISNULL(PA_157, 0),
    #LineasPresupuestoMesInformacion.ManodeObraExtranjero = ISNULL(PA_158, 0),
    #LineasPresupuestoMesInformacion.BienesContNac = ISNULL(PA_159, 0),
    #LineasPresupuestoMesInformacion.BienesExtranjero = ISNULL(PA_160, 0),
    #LineasPresupuestoMesInformacion.ServiciosContNac = ISNULL(PA_161, 0),
    #LineasPresupuestoMesInformacion.ServiciosExtranjero = ISNULL(PA_162, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónContNac = ISNULL(PA_163, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónExtranjero = ISNULL(PA_164, 0),
    #LineasPresupuestoMesInformacion.TransferenciadeTecnología = ISNULL(PA_165, 0),
    #LineasPresupuestoMesInformacion.Infraestructura = ISNULL(PA_166, 0)
FROM
    #LineasPresupuestoMesInformacion
    JOIN
        CO_BitacoraPresupuestoDetalle
            ON #LineasPresupuestoMesInformacion.IdBitacoraPresupuestoDetalle = CO_BitacoraPresupuestoDetalle.Id
               AND NumeroDeMes = 15
               AND (
                       ISNULL(PA_157, 0) > 0
                       OR ISNULL(PA_158, 0) > 0
                       OR ISNULL(PA_159, 0) > 0
                       OR ISNULL(PA_160, 0) > 0
                       OR ISNULL(PA_161, 0) > 0
                       OR ISNULL(PA_162, 0) > 0
                       OR ISNULL(PA_163, 0) > 0
                       OR ISNULL(PA_164, 0) > 0
                       OR ISNULL(PA_165, 0) > 0
                       OR ISNULL(PA_166, 0) > 0
                   );
UPDATE
    #LineasPresupuestoMesInformacion
SET
    #LineasPresupuestoMesInformacion.ManodeObraContNac = ISNULL(PA_167, 0),
    #LineasPresupuestoMesInformacion.ManodeObraExtranjero = ISNULL(PA_168, 0),
    #LineasPresupuestoMesInformacion.BienesContNac = ISNULL(PA_169, 0),
    #LineasPresupuestoMesInformacion.BienesExtranjero = ISNULL(PA_170, 0),
    #LineasPresupuestoMesInformacion.ServiciosContNac = ISNULL(PA_171, 0),
    #LineasPresupuestoMesInformacion.ServiciosExtranjero = ISNULL(PA_172, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónContNac = ISNULL(PA_173, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónExtranjero = ISNULL(PA_174, 0),
    #LineasPresupuestoMesInformacion.TransferenciadeTecnología = ISNULL(PA_175, 0),
    #LineasPresupuestoMesInformacion.Infraestructura = ISNULL(PA_176, 0)
FROM
    #LineasPresupuestoMesInformacion
    JOIN
        CO_BitacoraPresupuestoDetalle
            ON #LineasPresupuestoMesInformacion.IdBitacoraPresupuestoDetalle = CO_BitacoraPresupuestoDetalle.Id
               AND NumeroDeMes = 16
               AND (
                       ISNULL(PA_167, 0) > 0
                       OR ISNULL(PA_168, 0) > 0
                       OR ISNULL(PA_169, 0) > 0
                       OR ISNULL(PA_170, 0) > 0
                       OR ISNULL(PA_171, 0) > 0
                       OR ISNULL(PA_172, 0) > 0
                       OR ISNULL(PA_173, 0) > 0
                       OR ISNULL(PA_174, 0) > 0
                       OR ISNULL(PA_175, 0) > 0
                       OR ISNULL(PA_176, 0) > 0
                   );
UPDATE
    #LineasPresupuestoMesInformacion
SET
    #LineasPresupuestoMesInformacion.ManodeObraContNac = ISNULL(PA_177, 0),
    #LineasPresupuestoMesInformacion.ManodeObraExtranjero = ISNULL(PA_178, 0),
    #LineasPresupuestoMesInformacion.BienesContNac = ISNULL(PA_179, 0),
    #LineasPresupuestoMesInformacion.BienesExtranjero = ISNULL(PA_180, 0),
    #LineasPresupuestoMesInformacion.ServiciosContNac = ISNULL(PA_181, 0),
    #LineasPresupuestoMesInformacion.ServiciosExtranjero = ISNULL(PA_182, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónContNac = ISNULL(PA_183, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónExtranjero = ISNULL(PA_184, 0),
    #LineasPresupuestoMesInformacion.TransferenciadeTecnología = ISNULL(PA_185, 0),
    #LineasPresupuestoMesInformacion.Infraestructura = ISNULL(PA_186, 0)
FROM
    #LineasPresupuestoMesInformacion
    JOIN
        CO_BitacoraPresupuestoDetalle
            ON #LineasPresupuestoMesInformacion.IdBitacoraPresupuestoDetalle = CO_BitacoraPresupuestoDetalle.Id
               AND NumeroDeMes = 17
               AND (
                       ISNULL(PA_177, 0) > 0
                       OR ISNULL(PA_178, 0) > 0
                       OR ISNULL(PA_179, 0) > 0
                       OR ISNULL(PA_180, 0) > 0
                       OR ISNULL(PA_181, 0) > 0
                       OR ISNULL(PA_182, 0) > 0
                       OR ISNULL(PA_183, 0) > 0
                       OR ISNULL(PA_184, 0) > 0
                       OR ISNULL(PA_185, 0) > 0
                       OR ISNULL(PA_186, 0) > 0
                   );
UPDATE
    #LineasPresupuestoMesInformacion
SET
    #LineasPresupuestoMesInformacion.ManodeObraContNac = ISNULL(PA_187, 0),
    #LineasPresupuestoMesInformacion.ManodeObraExtranjero = ISNULL(PA_188, 0),
    #LineasPresupuestoMesInformacion.BienesContNac = ISNULL(PA_189, 0),
    #LineasPresupuestoMesInformacion.BienesExtranjero = ISNULL(PA_190, 0),
    #LineasPresupuestoMesInformacion.ServiciosContNac = ISNULL(PA_191, 0),
    #LineasPresupuestoMesInformacion.ServiciosExtranjero = ISNULL(PA_192, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónContNac = ISNULL(PA_193, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónExtranjero = ISNULL(PA_194, 0),
    #LineasPresupuestoMesInformacion.TransferenciadeTecnología = ISNULL(PA_195, 0),
    #LineasPresupuestoMesInformacion.Infraestructura = ISNULL(PA_196, 0)
FROM
    #LineasPresupuestoMesInformacion
    JOIN
        CO_BitacoraPresupuestoDetalle
            ON #LineasPresupuestoMesInformacion.IdBitacoraPresupuestoDetalle = CO_BitacoraPresupuestoDetalle.Id
               AND NumeroDeMes = 18
               AND (
                       ISNULL(PA_187, 0) > 0
                       OR ISNULL(PA_188, 0) > 0
                       OR ISNULL(PA_189, 0) > 0
                       OR ISNULL(PA_190, 0) > 0
                       OR ISNULL(PA_191, 0) > 0
                       OR ISNULL(PA_192, 0) > 0
                       OR ISNULL(PA_193, 0) > 0
                       OR ISNULL(PA_194, 0) > 0
                       OR ISNULL(PA_195, 0) > 0
                       OR ISNULL(PA_196, 0) > 0
                   );
UPDATE
    #LineasPresupuestoMesInformacion
SET
    #LineasPresupuestoMesInformacion.ManodeObraContNac = ISNULL(PA_197, 0),
    #LineasPresupuestoMesInformacion.ManodeObraExtranjero = ISNULL(PA_198, 0),
    #LineasPresupuestoMesInformacion.BienesContNac = ISNULL(PA_199, 0),
    #LineasPresupuestoMesInformacion.BienesExtranjero = ISNULL(PA_200, 0),
    #LineasPresupuestoMesInformacion.ServiciosContNac = ISNULL(PA_201, 0),
    #LineasPresupuestoMesInformacion.ServiciosExtranjero = ISNULL(PA_202, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónContNac = ISNULL(PA_203, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónExtranjero = ISNULL(PA_204, 0),
    #LineasPresupuestoMesInformacion.TransferenciadeTecnología = ISNULL(PA_205, 0),
    #LineasPresupuestoMesInformacion.Infraestructura = ISNULL(PA_206, 0)
FROM
    #LineasPresupuestoMesInformacion
    JOIN
        CO_BitacoraPresupuestoDetalle
            ON #LineasPresupuestoMesInformacion.IdBitacoraPresupuestoDetalle = CO_BitacoraPresupuestoDetalle.Id
               AND NumeroDeMes = 19
               AND (
                       ISNULL(PA_197, 0) > 0
                       OR ISNULL(PA_198, 0) > 0
                       OR ISNULL(PA_199, 0) > 0
                       OR ISNULL(PA_200, 0) > 0
                       OR ISNULL(PA_201, 0) > 0
                       OR ISNULL(PA_202, 0) > 0
                       OR ISNULL(PA_203, 0) > 0
                       OR ISNULL(PA_204, 0) > 0
                       OR ISNULL(PA_205, 0) > 0
                       OR ISNULL(PA_206, 0) > 0
                   );
UPDATE
    #LineasPresupuestoMesInformacion
SET
    #LineasPresupuestoMesInformacion.ManodeObraContNac = ISNULL(PA_207, 0),
    #LineasPresupuestoMesInformacion.ManodeObraExtranjero = ISNULL(PA_208, 0),
    #LineasPresupuestoMesInformacion.BienesContNac = ISNULL(PA_209, 0),
    #LineasPresupuestoMesInformacion.BienesExtranjero = ISNULL(PA_210, 0),
    #LineasPresupuestoMesInformacion.ServiciosContNac = ISNULL(PA_211, 0),
    #LineasPresupuestoMesInformacion.ServiciosExtranjero = ISNULL(PA_212, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónContNac = ISNULL(PA_213, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónExtranjero = ISNULL(PA_214, 0),
    #LineasPresupuestoMesInformacion.TransferenciadeTecnología = ISNULL(PA_215, 0),
    #LineasPresupuestoMesInformacion.Infraestructura = ISNULL(PA_216, 0)
FROM
    #LineasPresupuestoMesInformacion
    JOIN
        CO_BitacoraPresupuestoDetalle
            ON #LineasPresupuestoMesInformacion.IdBitacoraPresupuestoDetalle = CO_BitacoraPresupuestoDetalle.Id
               AND NumeroDeMes = 20
               AND (
                       ISNULL(PA_207, 0) > 0
                       OR ISNULL(PA_208, 0) > 0
                       OR ISNULL(PA_209, 0) > 0
                       OR ISNULL(PA_210, 0) > 0
                       OR ISNULL(PA_211, 0) > 0
                       OR ISNULL(PA_212, 0) > 0
                       OR ISNULL(PA_213, 0) > 0
                       OR ISNULL(PA_214, 0) > 0
                       OR ISNULL(PA_215, 0) > 0
                       OR ISNULL(PA_216, 0) > 0
                   );
UPDATE
    #LineasPresupuestoMesInformacion
SET
    #LineasPresupuestoMesInformacion.ManodeObraContNac = ISNULL(PA_217, 0),
    #LineasPresupuestoMesInformacion.ManodeObraExtranjero = ISNULL(PA_218, 0),
    #LineasPresupuestoMesInformacion.BienesContNac = ISNULL(PA_219, 0),
    #LineasPresupuestoMesInformacion.BienesExtranjero = ISNULL(PA_220, 0),
    #LineasPresupuestoMesInformacion.ServiciosContNac = ISNULL(PA_221, 0),
    #LineasPresupuestoMesInformacion.ServiciosExtranjero = ISNULL(PA_222, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónContNac = ISNULL(PA_223, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónExtranjero = ISNULL(PA_224, 0),
    #LineasPresupuestoMesInformacion.TransferenciadeTecnología = ISNULL(PA_225, 0),
    #LineasPresupuestoMesInformacion.Infraestructura = ISNULL(PA_226, 0)
FROM
    #LineasPresupuestoMesInformacion
    JOIN
        CO_BitacoraPresupuestoDetalle
            ON #LineasPresupuestoMesInformacion.IdBitacoraPresupuestoDetalle = CO_BitacoraPresupuestoDetalle.Id
               AND NumeroDeMes = 21
               AND (
                       ISNULL(PA_217, 0) > 0
                       OR ISNULL(PA_218, 0) > 0
                       OR ISNULL(PA_219, 0) > 0
                       OR ISNULL(PA_220, 0) > 0
                       OR ISNULL(PA_221, 0) > 0
                       OR ISNULL(PA_222, 0) > 0
                       OR ISNULL(PA_223, 0) > 0
                       OR ISNULL(PA_224, 0) > 0
                       OR ISNULL(PA_225, 0) > 0
                       OR ISNULL(PA_226, 0) > 0
                   );
UPDATE
    #LineasPresupuestoMesInformacion
SET
    #LineasPresupuestoMesInformacion.ManodeObraContNac = ISNULL(PA_227, 0),
    #LineasPresupuestoMesInformacion.ManodeObraExtranjero = ISNULL(PA_228, 0),
    #LineasPresupuestoMesInformacion.BienesContNac = ISNULL(PA_229, 0),
    #LineasPresupuestoMesInformacion.BienesExtranjero = ISNULL(PA_230, 0),
    #LineasPresupuestoMesInformacion.ServiciosContNac = ISNULL(PA_231, 0),
    #LineasPresupuestoMesInformacion.ServiciosExtranjero = ISNULL(PA_232, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónContNac = ISNULL(PA_233, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónExtranjero = ISNULL(PA_234, 0),
    #LineasPresupuestoMesInformacion.TransferenciadeTecnología = ISNULL(PA_235, 0),
    #LineasPresupuestoMesInformacion.Infraestructura = ISNULL(PA_236, 0)
FROM
    #LineasPresupuestoMesInformacion
    JOIN
        CO_BitacoraPresupuestoDetalle
            ON #LineasPresupuestoMesInformacion.IdBitacoraPresupuestoDetalle = CO_BitacoraPresupuestoDetalle.Id
               AND NumeroDeMes = 22
               AND (
                       ISNULL(PA_227, 0) > 0
                       OR ISNULL(PA_228, 0) > 0
                       OR ISNULL(PA_229, 0) > 0
                       OR ISNULL(PA_230, 0) > 0
                       OR ISNULL(PA_231, 0) > 0
                       OR ISNULL(PA_232, 0) > 0
                       OR ISNULL(PA_233, 0) > 0
                       OR ISNULL(PA_234, 0) > 0
                       OR ISNULL(PA_235, 0) > 0
                       OR ISNULL(PA_236, 0) > 0
                   );

UPDATE
    #LineasPresupuestoMesInformacion
SET
    #LineasPresupuestoMesInformacion.ManodeObraContNac = ISNULL(PA_237, 0),
    #LineasPresupuestoMesInformacion.ManodeObraExtranjero = ISNULL(PA_238, 0),
    #LineasPresupuestoMesInformacion.BienesContNac = ISNULL(PA_239, 0),
    #LineasPresupuestoMesInformacion.BienesExtranjero = ISNULL(PA_240, 0),
    #LineasPresupuestoMesInformacion.ServiciosContNac = ISNULL(PA_241, 0),
    #LineasPresupuestoMesInformacion.ServiciosExtranjero = ISNULL(PA_242, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónContNac = ISNULL(PA_243, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónExtranjero = ISNULL(PA_244, 0),
    #LineasPresupuestoMesInformacion.TransferenciadeTecnología = ISNULL(PA_245, 0),
    #LineasPresupuestoMesInformacion.Infraestructura = ISNULL(PA_246, 0)
FROM
    #LineasPresupuestoMesInformacion
    JOIN
        CO_BitacoraPresupuestoDetalle
            ON #LineasPresupuestoMesInformacion.IdBitacoraPresupuestoDetalle = CO_BitacoraPresupuestoDetalle.Id
               AND NumeroDeMes = 23
               AND (
                       ISNULL(PA_237, 0) > 0
                       OR ISNULL(PA_238, 0) > 0
                       OR ISNULL(PA_239, 0) > 0
                       OR ISNULL(PA_240, 0) > 0
                       OR ISNULL(PA_241, 0) > 0
                       OR ISNULL(PA_242, 0) > 0
                       OR ISNULL(PA_243, 0) > 0
                       OR ISNULL(PA_244, 0) > 0
                       OR ISNULL(PA_245, 0) > 0
                       OR ISNULL(PA_246, 0) > 0
                   );
UPDATE
    #LineasPresupuestoMesInformacion
SET
    #LineasPresupuestoMesInformacion.ManodeObraContNac = ISNULL(PA_247, 0),
    #LineasPresupuestoMesInformacion.ManodeObraExtranjero = ISNULL(PA_248, 0),
    #LineasPresupuestoMesInformacion.BienesContNac = ISNULL(PA_249, 0),
    #LineasPresupuestoMesInformacion.BienesExtranjero = ISNULL(PA_250, 0),
    #LineasPresupuestoMesInformacion.ServiciosContNac = ISNULL(PA_251, 0),
    #LineasPresupuestoMesInformacion.ServiciosExtranjero = ISNULL(PA_252, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónContNac = ISNULL(PA_253, 0),
    #LineasPresupuestoMesInformacion.CapacitaciónExtranjero = ISNULL(PA_254, 0),
    #LineasPresupuestoMesInformacion.TransferenciadeTecnología = ISNULL(PA_255, 0),
    #LineasPresupuestoMesInformacion.Infraestructura = ISNULL(PA_256, 0)
FROM
    #LineasPresupuestoMesInformacion
    JOIN
        CO_BitacoraPresupuestoDetalle
            ON #LineasPresupuestoMesInformacion.IdBitacoraPresupuestoDetalle = CO_BitacoraPresupuestoDetalle.Id
               AND NumeroDeMes = 24
               AND (
                       ISNULL(PA_247, 0) > 0
                       OR ISNULL(PA_248, 0) > 0
                       OR ISNULL(PA_249, 0) > 0
                       OR ISNULL(PA_250, 0) > 0
                       OR ISNULL(PA_251, 0) > 0
                       OR ISNULL(PA_252, 0) > 0
                       OR ISNULL(PA_253, 0) > 0
                       OR ISNULL(PA_254, 0) > 0
                       OR ISNULL(PA_255, 0) > 0
                       OR ISNULL(PA_256, 0) > 0
                   );

update
    #LineasPresupuestoMesInformacion
set
    Monto = (ManodeObraExtranjero + BienesExtranjero + ServiciosExtranjero
             + CapacitaciónExtranjero + ManodeObraContNac + BienesContNac
             + ServiciosContNac + CapacitaciónContNac + TransferenciadeTecnología + Infraestructura
            )
FROM
    #LineasPresupuestoMesInformacion;

IF((SELECT
    COUNT(1)
FROM
    #LineasPresupuestoMesInformacion
WHERE
    monto > 0) > 0)
BEGIN
		INSERT INTO CO_PERIODOCONTRATO (IdContrato,NombrePeriodo,Inicio,Fin,CreadoPor,CreadoEl,Activo)
		SELECT @IdContratoSeleccionado, @NombrePeriodo,@Inicio,@Fin,@UsuarioId,GETDATE(),1;

		SELECT @IdPeriodoContrato = SCOPE_IDENTITY()

		INSERT INTO CO_ProgramaActividad(IdPeriodoContrato,IdTipoProgramaActividad,NombrePrograma,CreadoPor,CreadoEl,Activo)
		SELECT @IdPeriodoContrato,@IdTipoProgramaActividad, @NombreProgramaActividad,@UsuarioId, GETDATE(),1;

        SELECT @IdProgramaActividad = SCOPE_IDENTITY();

		INSERT INTO CO_AnioContractual (Anio,Inicio,Termino,IdContrato,CreadoPor)
		SELECT YEAR(@Inicio),@Inicio,@Fin,@IdContratoSeleccionado,@UsuarioId;

		SELECT @IdAnioContractual = SCOPE_IDENTITY();
		
		INSERT INTO	CO_Presupuesto(IdAnioContractual,IdProgramaActividad,Version,Nombre,Comentario,CreadoPor,CreadoEl,Activo,IdPresupuestoCNH,Actual,CIEP,ActivoProcura)
		SELECT	@IdAnioContractual,@IdProgramaActividad,@Version,@NombrePresupuesto, @Comentario,@UsuarioId, GETDATE(),1,'',1,0,1

		SELECT @IdPresupuesto	= SCOPE_IDENTITY();

		-- REGISTRO DE LINEAS PRESUPUESTO MESES:
		INSERT INTO CO_LineaPresupuestoMes(
								IdPresupuesto,
								IdTipoServicio,
								IdActividad,
								IdSubactividad,
								AC_TERMINADO,
								IdInstalacion,
								AC_PRESUP_MES,
								IdServicio,
								AC_FEC_INI,
								AC_FEC_FIN,
								IdActvidadHidrocarburo,
								ID_PADRE,
								IdArea,
								Volumetria,
								PrecioUnitario,
								Monto,
								IdUsuario,
								FecMovto,
								IdExcel,
								CPXOPX,
								Actividad,
								MesActividadIni,
								MesActividadFin,
								IdActividadPetrolera,
								IdSubactividadPetrolera,
								IdTareaPetrolera,
								MOExt,
								MOCNac,
								BSExt,
								BSCNac,
								CreadoPor,
								CAPEX,
								SExt,
								SNac,
								CExt,
								CNac,
								TTec,
								ISoc)
						SELECT  @IdPresupuesto, @IdTipoServicio,@IdActividad,@IdSubactividad,
						0,IdInstalacionTabla,FechaInicio,IdServicioTabla,FechaInicio,FechaFin,@IdActvidadHidrocarburo,
						0, @IdArea,0,0,Monto,@UsuarioId, GETDATE(),IdDetalle,CPXOPX,0,FechaInicio,FechaFin,IdActividadPetroleraTabla,IdSubactividadPetroleraTabla,IdTareaTabla,
						ManodeObraExtranjero,ManodeObraContNac,BienesExtranjero, BienesContNac,@UsuarioId,CAPEX,ServiciosExtranjero,ServiciosContNac,CapacitaciónExtranjero,
						CapacitaciónContNac,TransferenciadeTecnología,Infraestructura
						FROM
							#LineasPresupuestoMesInformacion
						WHERE
							ISNULL(#LineasPresupuestoMesInformacion.Monto,0 ) > 0;
						

						UPDATE CO_BitacoraPresupuesto
						SET	
							CO_BitacoraPresupuesto.IdPresupuesto = @IdPresupuesto
						FROM
							CO_BitacoraPresupuesto
						WHERE
							IdArchivoAWS = @IdArchivoAWS;

	END	
 COMMIT TRAN
    END TRY
    BEGIN CATCH
        SELECT @ErrorMessage = ERROR_MESSAGE()

        ROLLBACK TRAN

        RAISERROR(@ErrorMessage, 17, 1)
    END CATCH;
END
