IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_INS_CO_GuardadoDeCargaDePresupuestoCIEP'
    )
    DROP PROCEDURE USP_INS_CO_GuardadoDeCargaDePresupuestoCIEP;
GO

CREATE PROCEDURE [dbo].[USP_INS_CO_GuardadoDeCargaDePresupuestoCIEP] 
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
        Numero      int IDENTITY(1,1),
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
        IdExcel                        INT,
		IdArea	INT,
		IdTipoServicio	INT,
		TipoServicio VARCHAR(1000),
		IdActividad	INT,
		Actividad VARCHAR(1000),
		IdClasificacion INT,
		Clasificacion VARCHAR(1000),
		IdServicio INT ,
		Servicio VARCHAR(1000),
		IdRubro	INT,
		Rubro  VARCHAR(1000),
		IdInstalacion	INT	 NULL,
		Instalacion  VARCHAR(1000),
		FecMovto DATE,
        Monto     FLOAT        NULL
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
    @IdAreaContractual       INT,
	@IdAreaDesarrollo INT ;

Select
    @IdCarga                 = IdCarga,
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

SELECT @IdAreaDesarrollo = IdArea FROM CO_Area WHERE NombreArea = 'Desarrollo Software';

INSERT INTO #Meses
    (
       FechaInicio,
       FechaFin
    )
SELECT TOP 24 IdFecha, UltimoDiaMes FROM AP_Calendario WHERE IdFecha >=  @Inicio AND Dia = 1;

INSERT INTO #LineasPresupuestoMesInformacion
    (
         
        NumeroDeMes                      ,
        FechaInicio                      ,
        FechaFin                         ,
        IdBitacoraPresupuestoDetalle     ,
        IdCarga                          ,
        IdExcel                        ,
		IdArea	,
		TipoServicio ,
		Actividad,
		Clasificacion,
		Servicio,
		Rubro,
		Instalacion,
		FecMovto ,
        Monto
    )
            SELECT
                #Meses.Numero,
                #Meses.FechaInicio,
                #Meses.FechaFin,
                CO_BitacoraPresupuestoDetalleCIEP.Id,
                CO_BitacoraPresupuestoDetalleCIEP.IdCarga,
                CO_BitacoraPresupuestoDetalleCIEP.IdExcel,
				@IdAreaDesarrollo,
				CuentaOperativa,
				Actividad,
				Clasificacion,
				Servicios,
				Rubro,
				Instalacion,
				getdate(),
				CASE #Meses.Numero
				WHEN 1 THEN MES1
				WHEN 2 THEN MES2
				WHEN 3 THEN MES3
				WHEN 4 THEN MES4
				WHEN 5 THEN MES5
				WHEN 6 THEN MES6
				WHEN 7 THEN MES7
				WHEN 8 THEN MES8
				WHEN 9 THEN MES9
				WHEN 10 THEN MES10
				WHEN 11 THEN MES11
				WHEN 12 THEN MES12
				WHEN 13 THEN MES13
				WHEN 14 THEN MES14
				WHEN 15 THEN MES15
				WHEN 16 THEN MES16
				WHEN 17 THEN MES17
				WHEN 18 THEN MES18
				WHEN 19 THEN MES19
				WHEN 20 THEN MES20
				WHEN 21 THEN MES21
				WHEN 22 THEN MES22
				WHEN 23 THEN MES23
				WHEN 24 THEN MES24
				END
            FROM
                CO_BitacoraPresupuestoDetalleCIEP
                CROSS JOIN #Meses
            WHERE
                CO_BitacoraPresupuestoDetalleCIEP.IdCarga = @IdCarga


UPDATE
    #LineasPresupuestoMesInformacion
SET
    #LineasPresupuestoMesInformacion.IdTipoServicio = CO_TipoServicio.IdTipoServicio
FROM
    #LineasPresupuestoMesInformacion
    JOIN
        CO_TipoServicio
            ON UPPER(LTRIM(RTRIM(ISNULL(#LineasPresupuestoMesInformacion.TipoServicio, '')))) = UPPER(LTRIM(RTRIM(ISNULL(CO_TipoServicio.NombreTipoServicio, ''))))
			AND  ISNULL(CO_TipoServicio.Activo, 0) = 1;


UPDATE
    #LineasPresupuestoMesInformacion
SET
    #LineasPresupuestoMesInformacion.IdActividad = CO_ActividadCIEP.IdActividad
FROM
    #LineasPresupuestoMesInformacion
    JOIN
        CO_ActividadCIEP
            ON UPPER(LTRIM(RTRIM(ISNULL(#LineasPresupuestoMesInformacion.Actividad, '')))) = UPPER(LTRIM(RTRIM(ISNULL(CO_ActividadCIEP.NombreActividad, ''))))
			AND CO_ActividadCIEP.IdContrato = @IdContratoSeleccionado
			WHERE
				CO_ActividadCIEP.IdContrato = @IdContratoSeleccionado

UPDATE
    #LineasPresupuestoMesInformacion
SET
    #LineasPresupuestoMesInformacion.IdServicio = CO_Servicio.IdServicio
FROM
    #LineasPresupuestoMesInformacion
    JOIN
        CO_Servicio
            ON UPPER(LTRIM(RTRIM(ISNULL(#LineasPresupuestoMesInformacion.Servicio, '')))) =UPPER(LTRIM(RTRIM(ISNULL(CO_Servicio.NombreServicio, ''))))
WHERE
    CO_Servicio.IdContrato = @IdContratoSeleccionado
    AND ISNULL(CO_Servicio.Activo, 0) = 1;


UPDATE
    #LineasPresupuestoMesInformacion
SET
    #LineasPresupuestoMesInformacion.IdRubro = CO_Rubro.IdRubro
FROM
    #LineasPresupuestoMesInformacion
    JOIN
        CO_Rubro
            ON UPPER(LTRIM(RTRIM(ISNULL(#LineasPresupuestoMesInformacion.Rubro, '')))) = UPPER(LTRIM(RTRIM(ISNULL(CO_Rubro.NombreRubro, ''))))
			AND  ISNULL(CO_Rubro.Activo, 0) = 1;

UPDATE
    #LineasPresupuestoMesInformacion
SET
    #LineasPresupuestoMesInformacion.IdClasificacion = CO_Clasificacion.IdClasificacion
FROM
    #LineasPresupuestoMesInformacion
    JOIN
        CO_Clasificacion
            ON UPPER(LTRIM(RTRIM(ISNULL(#LineasPresupuestoMesInformacion.Clasificacion, '')))) = UPPER(LTRIM(RTRIM(ISNULL(CO_Clasificacion.NombreClasificacion, ''))))

UPDATE
    #LineasPresupuestoMesInformacion
SET
    #LineasPresupuestoMesInformacion.IdInstalacion = CO_Instalacion.IdInstalacion
FROM
    #LineasPresupuestoMesInformacion
    JOIN
        CO_Instalacion
            ON UPPER(LTRIM(RTRIM(ISNULL(#LineasPresupuestoMesInformacion.Instalacion, '')))) 
			 = UPPER(LTRIM(RTRIM(ISNULL(CO_Instalacion.NombreInstalacion, ''))))
			AND  ISNULL(CO_Instalacion.Activo, 0) = 1
			AND CO_Instalacion.IdAreaContractual = @IdAreaContractual;


IF((SELECT
    COUNT(1)
FROM
    #LineasPresupuestoMesInformacion
WHERE
    monto > 0) > 0)
BEGIN
		IF (
			SELECT COUNT(1) 
			FROM CO_PERIODOCONTRATO 
			WHERE IdContrato = @IdContratoSeleccionado 
				AND LTRIM(RTRIM(UPPER(NombrePeriodo))) = LTRIM(RTRIM(UPPER(@NombrePeriodo)))
		) > 0
		BEGIN 
			SELECT TOP 1 
				@IdPeriodoContrato = IdPeriodo 
			FROM CO_PERIODOCONTRATO 
			WHERE IdContrato = @IdContratoSeleccionado 
				AND LTRIM(RTRIM(UPPER(NombrePeriodo))) = LTRIM(RTRIM(UPPER(@NombrePeriodo)))
		END 
		ELSE 
		BEGIN
			INSERT INTO CO_PERIODOCONTRATO (
				IdContrato, NombrePeriodo, Inicio, Fin, CreadoPor, CreadoEl, Activo
			)
			SELECT 
				@IdContratoSeleccionado, @NombrePeriodo, @Inicio, @Fin, @UsuarioId, GETDATE(), 1;

			SELECT @IdPeriodoContrato = SCOPE_IDENTITY()
		END		

		INSERT INTO CO_ProgramaActividad(IdPeriodoContrato,IdTipoProgramaActividad,NombrePrograma,CreadoPor,CreadoEl,Activo)
		SELECT @IdPeriodoContrato,@IdTipoProgramaActividad, @NombreProgramaActividad,@UsuarioId, GETDATE(),1;

        SELECT @IdProgramaActividad = SCOPE_IDENTITY();

		INSERT INTO CO_AnioContractual (Anio,Inicio,Termino,IdContrato,CreadoPor)
		SELECT YEAR(@Inicio),@Inicio,@Fin,@IdContratoSeleccionado,@UsuarioId;

		SELECT @IdAnioContractual = SCOPE_IDENTITY();
		
		INSERT INTO	CO_Presupuesto(IdAnioContractual,IdProgramaActividad,Version,Nombre,Comentario,CreadoPor,CreadoEl,Activo,IdPresupuestoCNH,Actual,CIEP,ActivoProcura)
		SELECT	@IdAnioContractual,@IdProgramaActividad,@Version,@NombrePresupuesto, @Comentario,@UsuarioId, GETDATE(),1,'',1,1,1

		SELECT @IdPresupuesto	= SCOPE_IDENTITY();

		-- REGISTRO DE LINEAS PRESUPUESTO MESES:
		INSERT INTO CO_LineaPresupuestoMes(
								IdPresupuesto,
								IdTipoServicio,
								IdActividad,
								 IdClasificacion, 
								AC_PRESUP_MES,
								IdServicio,
								AC_FEC_INI,
								AC_FEC_FIN,
								IdArea,
								IdRubro,
								Volumetria,
								PrecioUnitario,
								Monto,
								IdUsuario,
								FecMovto,
								IdExcel,
								IdInstalacion)
						SELECT  @IdPresupuesto, 
						IdTipoServicio,
						IdActividad,
						IdClasificacion,
						FechaInicio,
						IdServicio,
						FechaInicio,
						FechaFin,
						IdArea,
						IdRubro,
						1,
						0,
						Monto,
						@UsuarioId, 
						GETDATE(),
						IdExcel,
						IdInstalacion
						FROM
							#LineasPresupuestoMesInformacion
						WHERE
							ISNULL(#LineasPresupuestoMesInformacion.Monto,0 ) > 0
					   ORDER BY IdExcel;
						

						UPDATE CO_BitacoraPresupuesto
						SET	
							CO_BitacoraPresupuesto.IdPresupuesto = @IdPresupuesto,
							CO_BitacoraPresupuesto.DetalleInsercion = CONCAT('Presupuesto ',@NombrePresupuesto, ' registrado correctamente')
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
