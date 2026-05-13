USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'FN_CarsoObtenerLineaPresupuesto'
)
    DROP FUNCTION FN_CarsoObtenerLineaPresupuesto;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  UserDefinedFunction [dbo].[FN_CarsoObtenerLineaPresupuesto]    Script Date: 13/02/2025 09:21:39 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FN_CarsoObtenerLineaPresupuesto]
(
    @LP VARCHAR(150),
    @Mes VARCHAR(50),
    @IdContrato INT
)
-- =============================================
-- Author:		Pedro Acuña
-- Create date: 27/05/2019
-- Description: Retorna la linea de presupuesto mes
-- =============================================
-- 2021/ENERO	BAAC	Optimización
-- =============================================
-- 2025/FEBRERO	DAC	Se agrega que tome el presupuesto del mes y del año actual, si no se encuentra que tome el default
-- =============================================
RETURNS INT
AS
BEGIN

DECLARE @TablaLP TABLE
(
    IdLP INT IDENTITY(1, 1),
    Presupuesto VARCHAR(100),
    Actividad VARCHAR(500),
    SubActividad VARCHAR(500),
    Tarea VARCHAR(500),
    SubTarea VARCHAR(500),
    AnioContractual INT,
    IdPresupuesto INT
)

DECLARE @CONTPUNTOS INT ,
     @LONGITUD INT = 7,
     @POSICION1 INT,
     @POSICION2 INT,
     @POSICION3 INT,
     @POSICION4 INT,
     @STARLOC INT = 1,
     @IdLineaRetorno INT,
     @Presupuesto VARCHAR(100)

	SELECT @CONTPUNTOS = (LEN(@LP) - LEN(REPLACE(@LP, '.', '')))

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
			LP.IdPresupuesto = anio.IdPresupuesto,
			@Presupuesto = CONVERT(VARCHAR(100),anio.AnioLinea)
    FROM
		@TablaLP LP
	JOIN
		Petrovendor.dbo.AX_AnioContractual anio	(NOLOCK)
        ON	LP.Presupuesto	=	CONVERT(VARCHAR(100),anio.AnioLinea)
	JOIN		-- SE AGREGA JOIN A TABLA DE PRESUPUESTO POR CASO DE PRESUPUESTO CON LA MISMA CLAVE EN LOS DOS BLOQUES, PARA DIFERENCIAR POR EL CONTRATO ENVIADO
		Adinco.dbo.CO_Presupuesto	P (NOLOCK)
		ON	anio.IdPresupuesto	=	P.IdPresupuesto
	JOIN
		Adinco.dbo.CO_AnioContractual	AC (NOLOCK)
		ON	P.IdAnioContractual	=	AC.IdAnioContractual
		AND	AC.IdContrato	=	@IdContrato


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
            JOIN Adinco.dbo.CO_ActividadPetroleraCNH AS AP	(NOLOCK)
                ON LP.Actividad COLLATE DATABASE_DEFAULT = AP.id_Actividad
            JOIN Adinco.dbo.CO_SubactividadPetrolera AS SP	(NOLOCK)
                ON LP.SubActividad	=	SP.[id_Sub-actividad] COLLATE DATABASE_DEFAULT
            JOIN Adinco.dbo.CO_TareaPetrolera AS TP	(NOLOCK)
                ON LP.Tarea COLLATE DATABASE_DEFAULT	=	TP.id_Tarea
            JOIN Adinco.dbo.CO_Servicio AS CS	(NOLOCK)
                ON LP.SubTarea COLLATE DATABASE_DEFAULT = SUBSTRING(CS.NombreServicio, 1, @LONGITUD)
                   AND CS.IdContrato = @IdContrato
			JOIN Adinco.dbo.CO_AnioContractual AC	(NOLOCK)
				ON	LP.AnioContractual	=	AC.Anio
				AND AC.IdContrato = @IdContrato
			JOIN Adinco.dbo.CO_Presupuesto P	(NOLOCK)
                ON	AC.IdAnioContractual	=	P.IdAnioContractual
            JOIN Adinco.dbo.CO_LineaPresupuestoMes AS LPM	(NOLOCK)
                ON 	P.IdPresupuesto	=	LPM.IdPresupuesto
					AND	AP.IdActividadPetrolera	=	LPM.IdActividadPetrolera
                   AND SP.IdSubactividadPetrolera	=	LPM.IdSubactividadPetrolera
                   AND TP.IdTareaPetrolera	=	LPM.IdTareaPetrolera
                   AND CS.IdServicio	=	LPM.IdServicio
                   AND MONTH(LPM.AC_PRESUP_MES) = @Mes
        WHERE AC.Anio = LP.AnioContractual AND P.Actual = 1
    END
    ELSE
    BEGIN
        SELECT @IdLineaRetorno = LPM.IdLineaPresupuestoMes
        FROM @TablaLP AS LP
            JOIN Adinco.dbo.CO_ActividadPetroleraCNH AS AP	(NOLOCK)
                ON LP.Actividad COLLATE DATABASE_DEFAULT = AP.id_Actividad
            JOIN Adinco.dbo.CO_SubactividadPetrolera AS SP	(NOLOCK)
                ON LP.SubActividad COLLATE DATABASE_DEFAULT = SP.[id_Sub-actividad]
            JOIN Adinco.dbo.CO_TareaPetrolera AS TP	(NOLOCK)
                ON LP.Tarea = TP.id_Tarea  COLLATE DATABASE_DEFAULT
            JOIN Adinco.dbo.CO_Servicio AS CS	(NOLOCK)
                ON LP.SubTarea COLLATE DATABASE_DEFAULT = SUBSTRING(CS.NombreServicio, 1, @LONGITUD)
                   AND CS.IdContrato = @IdContrato
			 JOIN Adinco.dbo.CO_Presupuesto P	(NOLOCK)
                ON LP.IdPresupuesto	=	P.IdPresupuesto
            JOIN Adinco.dbo.CO_LineaPresupuestoMes AS LPM	(NOLOCK)
                ON P.IdPresupuesto = LPM.IdPresupuesto
				AND	AP.IdActividadPetrolera = LPM.IdActividadPetrolera
                   AND SP.IdSubactividadPetrolera = LPM.IdSubactividadPetrolera 
                   AND TP.IdTareaPetrolera = LPM.IdTareaPetrolera 
                   AND CS.IdServicio = LPM.IdServicio 
                   AND MONTH(LPM.AC_PRESUP_MES) = @Mes
				   AND YEAR(LPM.AC_PRESUP_MES) =  YEAR(GETDATE()) --> CTE DEBE SER DEL AÑO ACTUAL
            JOIN Adinco.dbo.CO_AnioContractual AC	(NOLOCK)
                ON P.IdAnioContractual = AC.IdAnioContractual
                   AND AC.IdContrato = @IdContrato
        WHERE AC.Anio = LP.AnioContractual
              AND LPM.IdPresupuesto = LP.IdPresupuesto
			  AND P.Actual = 1
		
		IF ISNULL(@IdLineaRetorno,0) = 0
		BEGIN 
		--> SI NO SE ENCONTRO LA DEL AÑO ACTUAL ENTONCES TRATAR DE IR LA LA DEFAULT
			SELECT @IdLineaRetorno = LPM.IdLineaPresupuestoMes
			FROM @TablaLP AS LP
				JOIN Adinco.dbo.CO_ActividadPetroleraCNH AS AP	(NOLOCK)
					ON LP.Actividad COLLATE DATABASE_DEFAULT = AP.id_Actividad
				JOIN Adinco.dbo.CO_SubactividadPetrolera AS SP	(NOLOCK)
					ON LP.SubActividad COLLATE DATABASE_DEFAULT = SP.[id_Sub-actividad]
				JOIN Adinco.dbo.CO_TareaPetrolera AS TP	(NOLOCK)
					ON LP.Tarea = TP.id_Tarea  COLLATE DATABASE_DEFAULT
				JOIN Adinco.dbo.CO_Servicio AS CS	(NOLOCK)
					ON LP.SubTarea COLLATE DATABASE_DEFAULT = SUBSTRING(CS.NombreServicio, 1, @LONGITUD)
					   AND CS.IdContrato = @IdContrato
				 JOIN Adinco.dbo.CO_Presupuesto P	(NOLOCK)
					ON LP.IdPresupuesto	=	P.IdPresupuesto
				JOIN Adinco.dbo.CO_LineaPresupuestoMes AS LPM	(NOLOCK)
					ON P.IdPresupuesto = LPM.IdPresupuesto
					AND	AP.IdActividadPetrolera = LPM.IdActividadPetrolera
					   AND SP.IdSubactividadPetrolera = LPM.IdSubactividadPetrolera 
					   AND TP.IdTareaPetrolera = LPM.IdTareaPetrolera 
					   AND CS.IdServicio = LPM.IdServicio 
					   AND MONTH(LPM.AC_PRESUP_MES) = @Mes
				JOIN Adinco.dbo.CO_AnioContractual AC	(NOLOCK)
					ON P.IdAnioContractual = AC.IdAnioContractual
					   AND AC.IdContrato = @IdContrato
			  WHERE AC.Anio = LP.AnioContractual
				  AND LPM.IdPresupuesto = LP.IdPresupuesto
				  AND P.Actual = 1
		END
    END

    RETURN @IdLineaRetorno
END
