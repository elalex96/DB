-- =============================================
-- Author:		Manuel CD
-- Create date: 19-10-17
-- Description:	
-- =============================================
-- Modificador:	Neri del Angel
-- Fecha:		19 de Octubre del 2022
-- Descripción:	Se agregan no lock faltantes, se ajusta la consulta a lo deseado
--				Se respeta que el filtrado de mes y año sea por el mes presentación del gasto (CO_registro)
--				Los campos GE_NO_COMPROBANTE, GE_MONTO, GE_PROVEEDOR y GE_DESCRIPCION se obtienen de vista GastosAmatitlan2020
--				EL campo de Actividad [ID_ADMON] se obtiene de CO_Instalacion.IdInstalacionPemex
--				El campo GE_REF_DOCUMENTO se queda en blanco, el campo GE_MES se obtiene del mes en que aprobó Pemex CO_RegistroMarkup.MesEstadoPemex
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_LayoutGastosElegibles]
    @IdPresupuesto INT,
    @IdActividad INT,
    @Anio INT,
    @Mes INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Contrato INT;
    DECLARE @Etiqueta1 NVARCHAR(50);
    DECLARE @Registros INT = 0;

    CREATE TABLE #TmpGastosElegibles
    (
        ID_CATACTIV INT NULL,
        ID_CATSUBACTIV INT NULL,
        PR_ANO INT NULL,
        PR_VERSION INT NULL,
        AC_MES INT NULL,
        Actividad INT NULL,
        GE_NO_COMPROBANTE VARCHAR(20),
        GE_MONTO DECIMAL(18, 2),
        GE_REF_DOCUMENTO VARCHAR(50),
        GE_PROVEEDOR VARCHAR(50),
        GE_DESCRIPCION VARCHAR(150),
        GE_MES INT NULL,
        Etiqueta1 VARCHAR(20)
    );

    SELECT @Etiqueta1 = 'ID_ADMON'
    WHERE @IdActividad = 1;
    SELECT @Etiqueta1 = 'ID_DUCTO'
    WHERE @IdActividad = 2;
    SELECT @Etiqueta1 = 'ID_ESTUDIO'
    WHERE @IdActividad = 3;
    SELECT @Etiqueta1 = 'ID_INSTALA'
    WHERE @IdActividad = 4;
    SELECT @Etiqueta1 = 'ID_POZO'
    WHERE @IdActividad = 5;
    /**/
    INSERT INTO #TmpGastosElegibles
    (
        ID_CATACTIV,
        ID_CATSUBACTIV,
        PR_ANO,
        PR_VERSION,
        AC_MES,
        Actividad,
        GE_NO_COMPROBANTE,
        GE_MONTO,
        GE_REF_DOCUMENTO,
        GE_PROVEEDOR,
        GE_DESCRIPCION,
        GE_MES,
        Etiqueta1
    )
    SELECT CO_ActividadCIEP.ID_CATACTIV AS ID_CATACTIV,
           CO_SubactividadCIEP.ID_CATSUBACTIV AS ID_CATSUBACTIV,
           YEAR(CO_LineaPresupuestoMes.AC_FEC_FIN) AS PR_ANO,
           ISNULL(CO_Presupuesto.Version, 1) AS PR_VERSION,
           @Mes AS AC_MES,
           ISNULL(CO_Instalacion.IdInstalacionPemex, '') AS Actividad,
           ISNULL(CAST(GastosAmatitlan2020.Numero AS VARCHAR(20)), '') AS GE_NO_COMPROBANTE,
           ISNULL(GastosAmatitlan2020.MontoUSDConMarkup, 0.00) AS GE_MONTO,
           '' AS GE_REF_DOCUMENTO, 
           ISNULL(CAST(GastosAmatitlan2020.Subcontratista AS VARCHAR(50)), '') AS GE_PROVEEDOR,
           ISNULL(CAST(GastosAmatitlan2020.Comentarios AS VARCHAR(150)), '') AS GE_DESCRIPCION,
           ISNULL(MONTH(CO_RegistroMarkup.MesEstadoPemex), '') AS GE_MES,
           @Etiqueta1 AS Etiqueta1
    FROM GastosAmatitlan2020 (NOLOCK)
        JOIN CO_LineaPresupuestoMes (NOLOCK)
            ON GastosAmatitlan2020.[Estatus Certificado] = 'Certificado GE Aprobado CACI'
               AND GastosAmatitlan2020.LineaPresupuesto = CO_LineaPresupuestoMes.IdLineaPresupuestoMes
        JOIN CO_RegistroMarkup (NOLOCK)
            ON GastosAmatitlan2020.IdRegistro = CO_RegistroMarkup.GastoId
        JOIN CO_ActividadCIEP (NOLOCK)
            ON CO_LineaPresupuestoMes.IdActividad = CO_ActividadCIEP.IdActividad
        LEFT JOIN CO_Instalacion (NOLOCK)
            ON CO_LineaPresupuestoMes.IdInstalacion = CO_Instalacion.IdInstalacion
        LEFT JOIN CO_SubactividadCIEP (NOLOCK)
            ON CO_LineaPresupuestoMes.IdSubactividad = CO_SubactividadCIEP.IdSubactividad
        LEFT JOIN CO_Presupuesto (NOLOCK)
            ON CO_LineaPresupuestoMes.IdPresupuesto = CO_Presupuesto.IdPresupuesto
    WHERE CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto
          AND CO_ActividadCIEP.ID_CATACTIV = @IdActividad
          AND MONTH(GastosAmatitlan2020.MesPresentacion) = @Mes
          AND YEAR(GastosAmatitlan2020.MesPresentacion) = @Anio;

    SELECT @Registros = COUNT(*)
    FROM #TmpGastosElegibles

    IF (@Registros = 0)
    BEGIN

        INSERT INTO #TmpGastosElegibles
        (
            Etiqueta1
        )
        SELECT @Etiqueta1
    END;
    
    SELECT ID_CATACTIV,
           ID_CATSUBACTIV,
           PR_ANO,
           PR_VERSION,
           AC_MES,
           Actividad,
           GE_NO_COMPROBANTE,
           GE_MONTO,
           GE_REF_DOCUMENTO,
           GE_PROVEEDOR,
           GE_DESCRIPCION,
           GE_MES,
           Etiqueta1
    FROM #TmpGastosElegibles
END;