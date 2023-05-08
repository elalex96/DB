
-- =============================================
-- Author:		Manuel CD
-- Create date: 28-09-17
-- Description:	
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 15/12/2022
-- Description:	Se modifica el stored procedure para que tenga base de reporte de PAT de acuerdo 
--				a lo indicado en el issue 2358. (Se comenta la estrucutura de la version 1 de este reporte, por si cambian de desición)
-- =============================================
-- Modificador:	Neri del Angel
-- Fecha:		23 de Marzo del 2023
-- Descripción: Se ajusta que los valores de ID_CATSUBACTIV, ID_TIPOSER e ID_ADMON se obtengan de los nuevos campos con el mismo nombre de la tabla CO_LineaPresupuestoMes
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_LayoutInformeDeAvance] 
@IdPresupuesto INT,
@IdActividad   INT,
@Anio          INT,
@Mes INT

AS
     BEGIN
         SET NOCOUNT ON;

		 CREATE TABLE #InformeAvance(
		 ID_CATACTIV INT NULL ,
		 ID_CATSUBACTIV VARCHAR(150),
		 ID_TIPOSER VARCHAR(150),
		 AC_PRESUP_MES DECIMAL(18, 2),
		 AC_NOMBRE	VARCHAR(5000),
		 AC_DESCRIPCION	VARCHAR(5000),
		 AC_FEC_INI VARCHAR(5000),
		 AC_FEC_FIN VARCHAR(5000),
		 AC_TERMINADO VARCHAR(10),
		 Etiqueta1 VARCHAR(500),
		 Etiqueta2 VARCHAR(500),
		 ID_CATACTHC  INT NULL,
		 ID_ACTIVIDAD_P VARCHAR(500),
		 ID_INSTALACION VARCHAR(5000),
		 Columna VARCHAR(500),
		 NombreTipoServicio VARCHAR(5000)
		 );

		DECLARE 
		@Etiqueta1 NVARCHAR(50),
		@Etiqueta2 NVARCHAR(50),
        @NumeroRegistros INT = 0,
        @Nombre VARCHAR(100) = '424104804RA',
        @Archivo VARCHAR(100) = '',
		@Fecha DATE = GETDATE();

          
         SELECT @Etiqueta1 = 'ID_ADMON'           WHERE @IdActividad = 1;
         SELECT @Etiqueta1 = 'ID_DUCTO'           WHERE @IdActividad = 2;
         SELECT @Etiqueta1 = 'ID_ESTUDIO'         WHERE @IdActividad = 3;
         SELECT @Etiqueta1 = 'ID_INSTALA'         WHERE @IdActividad = 4;
         SELECT @Etiqueta1 = 'ID_POZO'            WHERE @IdActividad = 5;
         SELECT @Etiqueta1 = '-'				  WHERE @IdActividad = 6;
         SELECT @Etiqueta2 = 'AC_UNIDAD_INSTALA'  WHERE @IdActividad = 4;
         SELECT @Etiqueta2 = 'AC_PRODUCCION_POZO' WHERE @IdActividad = 5;
		
	---------------------------------------------------------
	-- Apartado nombre
	---------------------------------------------------------

    SELECT @Nombre = @Nombre + NombreActividad + 'D'
    FROM CO_ActividadCIEP (NOLOCK)
    WHERE ID_CATACTIV = @IdActividad

    SELECT @Nombre = @Nombre + CAST(YEAR(@Fecha) AS VARCHAR(10))

    SELECT @Nombre = @Nombre + CASE
                                   WHEN CAST(MONTH(@Fecha) AS INT) < 10 THEN
                                       '0' + CAST(MONTH(@Fecha) AS VARCHAR(10))
                                   ELSE
                                       CAST(MONTH(@Fecha) AS VARCHAR(10))
                               END

    SELECT @Nombre = @Nombre + CASE
                                   WHEN CAST(DAY(@Fecha) AS INT) < 10 THEN
                                       '0' + CAST(DAY(@Fecha) AS VARCHAR(10))
                                   ELSE
                                       CAST(DAY(@Fecha) AS VARCHAR(10))
                               END
   SELECT @Archivo = CASE
                          WHEN @IdActividad IN ( 1, 2, 3 ) THEN
                              'InfoAvance_V3'
                          ELSE
                              'InfoAvance_V2'
                      END

    DELETE FROM CO_NombreArchivoXtraReport
    WHERE Archivo = @Archivo

    INSERT INTO CO_NombreArchivoXtraReport
    (
        Archivo,
        NombreArchivo
    )
    VALUES
    (@Archivo, @Nombre);

	------------------------------------
	INSERT INTO #InformeAvance(
		 ID_CATACTIV,
		 ID_CATSUBACTIV,
		 ID_TIPOSER,
		 AC_PRESUP_MES,
		 AC_NOMBRE	,
		 AC_DESCRIPCION	,
		 AC_FEC_INI ,
		 AC_FEC_FIN ,
		 AC_TERMINADO,
		 Etiqueta1,
		 Etiqueta2,
		 ID_CATACTHC,
		 ID_ACTIVIDAD_P,
		 ID_INSTALACION,
		 Columna,
		 NombreTipoServicio )
	    SELECT AC.ID_CATACTIV,
               LP.ID_CATSUBACTIV,
               LP.ID_TIPOSER,
               CAST(SUM(LP.Monto) AS DECIMAL(15, 2)),
               SUBSTRING(S.NombreServicio, 0, 5000),
               SUBSTRING(S.NombreServicio, 0, 5000),
               CONVERT(CHAR(10), (DATEFROMPARTS(YEAR(LP.AC_FEC_INI), MONTH(LP.AC_FEC_INI), DAY(LP.AC_FEC_INI))), 103),
               CONVERT(CHAR(10), (DATEFROMPARTS(YEAR(LP.AC_FEC_FIN), MONTH(LP.AC_FEC_FIN), DAY(LP.AC_FEC_FIN))), 103),
               'S' AS [AC_TERMINADO],
		   @Etiqueta1 AS Etiqueta1,
		   @Etiqueta2 AS Etiqueta2,
           1 AS ID_CATACTHC,
           '' AS ID_ACTIVIDAD_P,
		   LP.ID_ADMON AS [ID_INSTALACION],
			CASE
				WHEN @IdActividad = 4
					THEN SUBSTRING(ISNULL(I.NombreInstalacion, 'AREA CONTRACTUAL AMATITLAN'),0,10)
				WHEN @IdActividad = 5
					THEN '0'
			END AS Columna,
			TS.NombreTipoServicio
        FROM CO_LineaPresupuestoMes LP (NOLOCK)
            JOIN CO_ActividadCIEP AC (NOLOCK)
                ON LP.IdActividad = AC.IdActividad
            LEFT JOIN CO_Servicio S (NOLOCK)
                ON LP.idServicio = S.IdServicio
            LEFT JOIN CO_SubactividadCIEP SA (NOLOCK)
                ON LP.IdSubactividad = SA.IdSubactividad
            LEFT JOIN CO_Instalacion I (NOLOCK)
                ON LP.IdInstalacion = I.IdInstalacion
            LEFT JOIN CO_TipoServicio TS (NOLOCK)
                ON LP.IdTipoServicio = TS.IdTipoServicio
            LEFT JOIN CO_ActividadHidrocarburoCIEP AH (NOLOCK)
                ON LP.IdActvidadHidrocarburo = AH.IdActividadHidrocarburo
        WHERE LP.IdPresupuesto = @IdPresupuesto
              AND AC.ID_CATACTIV = @IdActividad
			  AND YEAR(LP.AC_FEC_INI) = @Anio
        GROUP BY AC.ID_CATACTIV,
				LP.ID_CATSUBACTIV,
               LP.ID_TIPOSER,
                 S.NombreServicio,
                 SA.NombreSubactividad,
                 LP.AC_FEC_INI,
                 LP.AC_FEC_FIN,
                 ISNULL(I.IdInstalacionPemex, ''),
                 ah.ID_CATACTHC,
				  LP.ID_ADMON,
                 CASE
                     WHEN @IdActividad = 4 THEN
                         SUBSTRING(ISNULL(I.NombreInstalacion, 'AREA CONTRACTUAL AMATITLAN'), 0, 10)
                     WHEN @IdActividad = 5 THEN
                         '0'
                 END,
				TS.NombreTipoServicio;

		if((SELECT COUNT(1) FROM #InformeAvance)>0)
		BEGIN
		SELECT * FROM #InformeAvance
		ORDER BY AC_NOMBRE, NombreTipoServicio, AC_FEC_INI	ASC;
		END
		ELSE
		BEGIN
		 SELECT  
		   @Etiqueta1 AS Etiqueta1,
		   @Etiqueta2 AS Etiqueta2;
			
		END
		------------------------------------------------------------
--	SE COMENTA CODIGO YA QUE EN EL ISSUE 2358 SE ESTA SOLICITANDO CON INFORMACIÓN DE PRESUPUESTO,_
--  NO CON INFORMACIÓN DE GASTOS, POR EL CUAL YA NO SE REALIZARÁ JOIN CON VISTA GastosAmatitlan2020 SE BASARÁ EN LA CONSULTA DEL PAT	
/*
SELECT		CO_ActividadCIEP.ID_CATACTIV AS ID_CATACTIV,
           0 AS ID_CATSUBACTIV,
           CO_LineaPresupuestoMes.IdTipoServicio AS ID_TIPOSER,
           CAST(SUM(GastosAmatitlan2020.MontoUSDConMarkup) AS DECIMAL(18, 2)) AS AC_PRESUP_MES,
           SUBSTRING(GastosAmatitlan2020.Servicio, 0, 500) AS AC_NOMBRE,
           SUBSTRING(GastosAmatitlan2020.Servicio, 0, 10) AS AC_DESCRIPCION,
           CONVERT(CHAR(10), (DATEFROMPARTS(YEAR(GastosAmatitlan2020.FechaInicio), MONTH(GastosAmatitlan2020.FechaInicio), DAY(GastosAmatitlan2020.FechaInicio))), 103) AS AC_FEC_INI,
           CONVERT(CHAR(10), (DATEFROMPARTS(YEAR(GastosAmatitlan2020.FechaFin), MONTH(GastosAmatitlan2020.FechaFin), DAY(GastosAmatitlan2020.FechaFin))), 103) AS AC_FEC_FIN,
           'S' AS AC_TERMINADO,
           @Etiqueta1 AS Etiqueta1,
		   @Etiqueta2 AS Etiqueta2,
           1 AS ID_CATACTHC,
           0 AS ID_ACTIVIDAD_P,
           @Etiqueta2 AS Etiqueta2,
		   CASE
				WHEN @IdActividad = 4
					THEN  ISNULL(CO_Instalacion.IdInstalacionPemex,'500084001') 
				WHEN @IdActividad = 5
					THEN  '' -- se tiene que validar el pozo
				WHEN @IdActividad = 1
					THEN  ISNULL(CO_Instalacion.IdInstalacionPemex,'1')  --Esta es la instalacion que viene del gasto
				WHEN @IdActividad = 3
					THEN  ISNULL(CO_Instalacion.IdInstalacionPemex,'0') --  
				ELSE  
					ISNULL(CO_Instalacion.IdInstalacionPemex,'') 
                END AS [ID_INSTALACION],
			CASE
				WHEN @IdActividad = 4
					THEN SUBSTRING(ISNULL(CO_Instalacion.NombreInstalacion, 'AREA CONTRACTUAL AMATITLAN'),0,10)
				WHEN @IdActividad = 5
					THEN '0'
			END AS Columna,
			CO_TipoServicio.NombreTipoServicio
    FROM GastosAmatitlan2020 
		INNER JOIN CO_Registro (NOLOCK)
			ON GastosAmatitlan2020.IdRegistro = CO_Registro.IdRegistro
		INNER JOIN CO_ActividadCIEP (NOLOCK)
            ON UPPER(LTRIM(RTRIM(GastosAmatitlan2020.Actividad))) = UPPER(LTRIM(RTRIM((CO_ActividadCIEP.NombreActividad))))
			AND CO_ActividadCIEP.ID_CATACTIV = @IdActividad
		INNER JOIN CO_LineaPresupuestoMes (NOLOCK) 
			ON GastosAmatitlan2020.LineaPresupuesto =  CO_LineaPresupuestoMes.IdLineaPresupuestoMes
			AND CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto
		LEFT JOIN CO_Instalacion (NOLOCK) 
				ON CO_Registro.IdInstalacion = CO_Instalacion.IdInstalacion
		LEFT JOIN CO_TipoServicio (NOLOCK)
			ON UPPER(LTRIM(RTRIM(GastosAmatitlan2020.TipoDeServicio)))  =UPPER(LTRIM(RTRIM((CO_TipoServicio.NombreTipoServicio))))
   WHERE CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto
        AND CO_ActividadCIEP.ID_CATACTIV = @IdActividad
          AND YEAR(GastosAmatitlan2020.MesPresentacion) = @Anio
		  AND Month(GastosAmatitlan2020.MesPresentacion) = @Mes
    GROUP BY CO_LineaPresupuestoMes.IdTipoServicio,
				CO_ActividadCIEP.ID_CATACTIV,
			GastosAmatitlan2020.Servicio,
             GastosAmatitlan2020.FechaInicio,
             GastosAmatitlan2020.FechaFin,
			 CO_Instalacion.IdInstalacionPemex,
			 CO_Instalacion.NombreInstalacion,
			 CO_TipoServicio.NombreTipoServicio;
			 */
	END;
