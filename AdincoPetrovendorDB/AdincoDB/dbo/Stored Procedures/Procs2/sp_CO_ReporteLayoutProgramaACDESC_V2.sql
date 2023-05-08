
-- =============================================
-- Author:		Miguel Gomez
-- Create date: 
-- Description:	
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20/10/2022
-- Description:	se agregan los valores por si acaso es null de las instalaciones y los pozos
-- y se agrega la etiqueta y valores nuevos
-- =============================================
-- Author:		Neri del Angel
-- Create date: 08 de Diciembre del 2022
-- Description:	Se ajusta tamaño del texto de las columnas [AC_NOMBRE] y [AC_DESCRIPCION] a 5000 para enviar todo el texto
--				Se ajusta columna [ID Subatividad], [ID_TIPOSER] e [ID_INSTALACION] a vacio y 
--				se deja los codigos comentados ya que se planean re utilizar en la versión 3
--				Se agrega validación de @NumeroRegistros para que si es igual a 0 envíe las etiquetas @Label y @Etiqueta2,
--				para que se complete en nombre de las columnas que ocupan estas
--				Se agrega el nombrado de archivo para su uso durante la descarga de archivo
-- =============================================
-- Modificador:	Neri del Angel
-- Fecha:		23 de Marzo del 2023
-- Descripción: Se ajusta que los valores de ID_CATSUBACTIV, ID_TIPOSER e ID_ADMON se obtengan de los nuevos campos con el mismo nombre de la tabla CO_LineaPresupuestoMes
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ReporteLayoutProgramaACDESC_V2]
    @IdPresupuesto INT = 0,
    @Anio VARCHAR(10),
    @IdActividad INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Label VARCHAR(50),
            @Etiqueta2 VARCHAR(50),
            @NumeroRegistros INT = 0,
            @Nombre VARCHAR(100) = '424104804PT',
            @Archivo VARCHAR(100) = '',
			@Fecha DATE = GETDATE();

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

    SELECT @Label = CASE @IdActividad
                        WHEN 1 THEN
                            'ID_ADMON'
                        WHEN 2 THEN
                            'ID_DUCTO'
                        WHEN 3 THEN
                            'ID_ESTUDIO'
                        WHEN 4 THEN
                            'ID_INSTALA'
                        WHEN 5 THEN
                            'ID_POZO'
                        ELSE
                            ''
                    END,
           @Etiqueta2 = CASE @IdActividad
                            WHEN 4 THEN
                                'AC_UNIDAD_INSTALA'
                            WHEN 5 THEN
                                'AC_PRODUCCION_POZO'
                            ELSE
                                ''
                        END

    SELECT @Archivo = CASE
                          WHEN @IdActividad IN ( 1, 2, 3 ) THEN
                              'rpt_AmLayout_V2'
                          ELSE
                              'rpt_AmLayout_V3'
                      END

    DELETE FROM CO_NombreArchivoXtraReport
    WHERE Archivo = @Archivo

    INSERT INTO CO_NombreArchivoXtraReport
    (
        Archivo,
        NombreArchivo
    )
    VALUES
    (@Archivo, @Nombre)

    SELECT @NumeroRegistros = COUNT(*)
    FROM CO_LineaPresupuestoMes LP (NOLOCK)
        JOIN CO_ActividadCIEP AC (NOLOCK)
            ON LP.IdActividad = AC.IdActividad
    WHERE LP.IdPresupuesto = @IdPresupuesto
          AND AC.ID_CATACTIV = @IdActividad
          AND YEAR(LP.AC_FEC_INI) = YEAR(@Anio)

    IF (@NumeroRegistros > 0)
    BEGIN
        SELECT AC.ID_CATACTIV AS [ID_CATACTIV],
               LP.ID_CATSUBACTIV AS [ID Subatividad],
               LP.ID_TIPOSER AS [ID_TIPOSER],
               CAST(SUM(LP.Monto) AS DECIMAL(15, 2)) AS [AC_PRESUP_MES],
               SUBSTRING(S.NombreServicio, 0, 5000) AS [AC_NOMBRE],
               SUBSTRING(S.NombreServicio, 0, 5000) AS [AC_DESCRIPCION],
               CONVERT(CHAR(10), (DATEFROMPARTS(YEAR(LP.AC_FEC_INI), MONTH(LP.AC_FEC_INI), DAY(LP.AC_FEC_INI))), 103) AS [AC_FEC_INI],
               CONVERT(CHAR(10), (DATEFROMPARTS(YEAR(LP.AC_FEC_FIN), MONTH(LP.AC_FEC_FIN), DAY(LP.AC_FEC_FIN))), 103) AS [AC_FEC_FIN],
               'S' AS [AC_TERMINADO],
               --CASE
               --    WHEN @IdActividad = 4 THEN
               --        ISNULL(I.IdInstalacionPemex, '500084001')
               --    WHEN @IdActividad = 5 THEN
               --        ISNULL(I.IdInstalacionPemex, '300085036')
               --    WHEN @IdActividad = 1 THEN
               --        ISNULL(I.IdInstalacionPemex, '')
               --    WHEN @IdActividad = 3 THEN
               --        ISNULL(I.IdInstalacionPemex, '0')
               --    ELSE
               --        ISNULL(I.IdInstalacionPemex, '')
               --END AS [ID_INSTALACION],
               LP.ID_ADMON AS [ID_INSTALACION],
               1 AS [ID_CATACTHC],
               @Label AS Etiqueta,
               @Etiqueta2 AS Etiqueta2,
               CASE
                   WHEN @IdActividad = 4 THEN
                       SUBSTRING(ISNULL(I.NombreInstalacion, 'AREA CONTRACTUAL AMATITLAN'), 0, 10)
                   WHEN @IdActividad = 5 THEN
                       '0'
               END AS Columna
        FROM CO_LineaPresupuestoMes LP (NOLOCK)
            JOIN CO_ActividadCIEP AC (NOLOCK)
                ON LP.IdActividad = AC.IdActividad
            LEFT JOIN CO_Servicio S (NOLOCK)
                ON LP.idServicio = S.IdServicio
            --LEFT JOIN CO_SubactividadCIEP SA (NOLOCK)
            --    ON LP.IdSubactividad = SA.IdSubactividad
            LEFT JOIN CO_Instalacion I (NOLOCK)
                ON LP.IdInstalacion = I.IdInstalacion
            LEFT JOIN CO_TipoServicio TS (NOLOCK)
                ON LP.IdTipoServicio = TS.IdTipoServicio
            LEFT JOIN CO_ActividadHidrocarburoCIEP AH (NOLOCK)
                ON LP.IdActvidadHidrocarburo = AH.IdActividadHidrocarburo
        WHERE LP.IdPresupuesto = @IdPresupuesto
              AND AC.ID_CATACTIV = @IdActividad
              AND YEAR(LP.AC_FEC_INI) = YEAR(@Anio)
        GROUP BY AC.ID_CATACTIV,
                LP.ID_CATSUBACTIV,
                LP.ID_TIPOSER,
                 S.NombreServicio,
                --SA.NombreSubactividad,
                 LP.AC_FEC_INI,
                 LP.AC_FEC_FIN,
				 LP.ID_ADMON,
                 --CASE
                 --    WHEN @IdActividad = 4 THEN
                 --        ISNULL(I.IdInstalacionPemex, '500084001')
                 --    WHEN @IdActividad = 5 THEN
                 --        ISNULL(I.IdInstalacionPemex, '300085036')
                 --    WHEN @IdActividad = 1 THEN
                 --        ISNULL(I.IdInstalacionPemex, '1')
                 --    WHEN @IdActividad = 3 THEN
                 --        ISNULL(I.IdInstalacionPemex, '0')
                 --    ELSE
                 --        ISNULL(I.IdInstalacionPemex, '')
                 --END,
                 ISNULL(I.IdInstalacionPemex, ''),
                 ah.ID_CATACTHC,
                 CASE
                     WHEN @IdActividad = 4 THEN
                         SUBSTRING(ISNULL(I.NombreInstalacion, 'AREA CONTRACTUAL AMATITLAN'), 0, 10)
                     WHEN @IdActividad = 5 THEN
                         '0'
                 END
        ORDER BY [ID_TIPOSER] ASC;
    END
    ELSE
    BEGIN
        SELECT '' AS [ID_CATACTIV],
               '' AS [ID Subatividad],
               '' AS [ID_TIPOSER],
               '' AS [AC_PRESUP_MES],
               '' AS [AC_NOMBRE],
               '' AS [AC_DESCRIPCION],
               '' AS [AC_FEC_INI],
               '' AS [AC_FEC_FIN],
               '' AS [AC_TERMINADO],
               '' AS [ID_INSTALACION],
               '' AS [ID_CATACTHC],
               @Label AS Etiqueta,
               @Etiqueta2 AS Etiqueta2,
               '' AS Columna
    END
END;