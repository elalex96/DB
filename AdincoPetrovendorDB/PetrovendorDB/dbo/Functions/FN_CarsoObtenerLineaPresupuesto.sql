-- =============================================
-- Author:		Pedro Acuña
-- Create date: 27/05/2019
-- Description: Retorna la linea de presupuesto mes
-- =============================================
CREATE FUNCTION [dbo].[FN_CarsoObtenerLineaPresupuesto]
(
    @LP NVARCHAR(150),
    @Mes NVARCHAR(50),
    @IdContrato INT
)
RETURNS INT
AS
BEGIN
    -- P001.AC-1.SA-01.TA-003.STA-002 --205824  --abril 1
    --P001.AC-1.SA-07.TA-029.STA-020  -- 205843 -- febrero 1
    --'P001.AC-1.SA-07.TA-029.STA-020'  -- 205842  --enero 1
    --P001.AC-1.SA-01.TA-003.STA-002 -- 205821  enero 1
    --DECLARE @LP VARCHAR (MAX) = 'P001.AC-1.SA-01.TA-003.STA-002';
    --DECLARE @Mes VARCHAR (MAX) = '01';
    --DECLARE @IDCONTRATO INT = 10047

    DECLARE @CONTPUNTOS INT =
            (
                SELECT (LEN(@LP) - LEN(REPLACE(@LP, '.', ''))) / LEN('.')
            );


    DECLARE @LONGITUD INT = 7
    DECLARE @POSICION1 INT
    DECLARE @POSICION2 INT
    DECLARE @POSICION3 INT
    DECLARE @POSICION4 INT
    DECLARE @STARLOC INT = 1;
    DECLARE @IdLineaRetorno INT,
            @Presupuesto NVARCHAR(100)


    DECLARE @TablaLP TABLE
    (
        IdLP INT IDENTITY(1, 1),
        Presupuesto VARCHAR(MAX),
        Actividad VARCHAR(MAX),
        SubActividad VARCHAR(MAX),
        Tarea VARCHAR(MAX),
        SubTarea VARCHAR(MAX),
        AnioContractual INT,
        IdPresupuesto INT
    )


    IF @CONTPUNTOS = 5
    BEGIN
        SELECT @POSICION1 = CHARINDEX('.', @LP, 1),
               @POSICION2 = CHARINDEX('.', @LP, @POSICION1 + 1);

        SET @STARLOC = @POSICION2;
    END

    SELECT @POSICION1 = CHARINDEX('.', @LP, @STARLOC),
           @POSICION2 = CHARINDEX('.', @LP, @POSICION1 + 1),
           @POSICION3 = CHARINDEX('.', @LP, @POSICION2 + 1),
           @POSICION4 = CHARINDEX('.', @LP, @POSICION3 + 1)



    INSERT INTO @TablaLP
    (
        Presupuesto,
        Actividad,
        SubActividad,
        Tarea,
        SubTarea
    )
    SELECT SUBSTRING(@LP, 1, @POSICION1 - 1),
           SUBSTRING(@LP, @POSICION1 + 1, (@POSICION2 - @POSICION1) - 1),
           SUBSTRING(@LP, @POSICION2 + 1, (@POSICION3 - @POSICION2) - 1),
           SUBSTRING(@LP, @POSICION3 + 1, (@POSICION4 - @POSICION3) - 1),
           SUBSTRING(@LP, @POSICION4 + 1, (LEN(@LP) - @POSICION4));


    UPDATE LP
    SET LP.AnioContractual = anio.AnioReal,
        LP.IdPresupuesto = anio.IdPresupuesto
    FROM Petrovendor.dbo.AX_AnioContractual anio
        INNER JOIN @TablaLP LP
            ON anio.AnioLinea = LP.Presupuesto

    SELECT @Presupuesto = Presupuesto
    FROM @TablaLP

	-- si esta dentro de los tres primeros presupuestos toma la logica anterior
	-- si es diferente entonces se toma la nueva logica donde se considera el idpresupuesto de la tabla AX_AnioContractual
	-- esto para descartar en caso de tener varios presupuestos en el mismo año
    IF (
           LTRIM(RTRIM(UPPER(@Presupuesto))) = 'P001'
           OR LTRIM(RTRIM(UPPER(@Presupuesto))) = 'P002'
           OR LTRIM(RTRIM(UPPER(@Presupuesto))) = 'P003'
       )
    BEGIN
        SELECT @IdLineaRetorno = LPM.IdLineaPresupuestoMes
        FROM @TablaLP AS LP
            LEFT JOIN Adinco.dbo.CO_ActividadPetroleraCNH AS AP
                ON LP.Actividad COLLATE DATABASE_DEFAULT = AP.id_Actividad
            LEFT JOIN Adinco.dbo.CO_SubactividadPetrolera AS SP
                ON SP.[id_Sub-actividad] COLLATE DATABASE_DEFAULT = LP.SubActividad
            LEFT JOIN Adinco.dbo.CO_TareaPetrolera AS TP
                ON TP.id_Tarea = LP.Tarea COLLATE DATABASE_DEFAULT
            LEFT JOIN Adinco.dbo.CO_Servicio AS CS
                ON LP.SubTarea COLLATE DATABASE_DEFAULT = SUBSTRING(CS.NombreServicio, 1, @LONGITUD)
                   AND CS.IdContrato = @IdContrato
            LEFT JOIN Adinco.dbo.CO_LineaPresupuestoMes AS LPM
                ON LPM.IdActividadPetrolera = AP.IdActividadPetrolera
                   AND LPM.IdSubactividadPetrolera = SP.IdSubactividadPetrolera
                   AND LPM.IdTareaPetrolera = TP.IdTareaPetrolera
                   AND LPM.IdServicio = CS.IdServicio
                   AND MONTH(LPM.AC_PRESUP_MES) = @Mes
            LEFT JOIN Adinco.dbo.CO_Presupuesto P
                ON LPM.IdPresupuesto = P.IdPresupuesto
            LEFT JOIN Adinco.dbo.CO_AnioContractual AC
                ON P.IdAnioContractual = AC.IdAnioContractual
                   AND AC.IdContrato = @IdContrato
        WHERE AC.Anio = LP.AnioContractual AND P.Actual = 1
    END
    ELSE
    BEGIN
        SELECT @IdLineaRetorno = LPM.IdLineaPresupuestoMes
        FROM @TablaLP AS LP
            LEFT JOIN Adinco.dbo.CO_ActividadPetroleraCNH AS AP
                ON LP.Actividad COLLATE DATABASE_DEFAULT = AP.id_Actividad
            LEFT JOIN Adinco.dbo.CO_SubactividadPetrolera AS SP
                ON SP.[id_Sub-actividad] COLLATE DATABASE_DEFAULT = LP.SubActividad
            LEFT JOIN Adinco.dbo.CO_TareaPetrolera AS TP
                ON TP.id_Tarea = LP.Tarea COLLATE DATABASE_DEFAULT
            LEFT JOIN Adinco.dbo.CO_Servicio AS CS
                ON LP.SubTarea COLLATE DATABASE_DEFAULT = SUBSTRING(CS.NombreServicio, 1, @LONGITUD)
                   AND CS.IdContrato = @IdContrato
            LEFT JOIN Adinco.dbo.CO_LineaPresupuestoMes AS LPM
                ON LPM.IdActividadPetrolera = AP.IdActividadPetrolera
                   AND LPM.IdSubactividadPetrolera = SP.IdSubactividadPetrolera
                   AND LPM.IdTareaPetrolera = TP.IdTareaPetrolera
                   AND LPM.IdServicio = CS.IdServicio
                   AND MONTH(LPM.AC_PRESUP_MES) = @Mes
            LEFT JOIN Adinco.dbo.CO_Presupuesto P
                ON LPM.IdPresupuesto = P.IdPresupuesto
            LEFT JOIN Adinco.dbo.CO_AnioContractual AC
                ON P.IdAnioContractual = AC.IdAnioContractual
                   AND AC.IdContrato = @IdContrato
        WHERE AC.Anio = LP.AnioContractual
              AND LPM.IdPresupuesto = LP.IdPresupuesto
			  AND P.Actual = 1
    END




    RETURN @IdLineaRetorno
END


