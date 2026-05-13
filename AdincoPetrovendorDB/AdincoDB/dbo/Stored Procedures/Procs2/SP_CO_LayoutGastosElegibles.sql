
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
-- Modificador:	Neri del Angel
-- Fecha:		13 de Diciembre del 2022
-- Descripción:	Se ajustan columnas ID_CATSUBACTIV y Actividad (ID_ADMINISTRACION, ID_DUCTOS, ID_ESTUDIOS, ID_ESTUDIOS, ID_INSTALACIONES e ID_POZOS) a vacío
--				Se ajustan PR_ANO, AC_MES y GE_MES Se mostrará de acuerdo con el año/mes que se selecciona en la descarga del presupuesto.
--				Se ajusta PR_VERSION a 1 por default
--				Se ajusto GE_NO_COMPROBANTE y GE_PROVEEDOR confirma si corresponde a una refactura y agrega el apartado de el número de folio y serie y
--				proveedor de ser el caso obtendrá los datos de la refactura (LUMEX)
--				Se ajusto GE_REF_DOCUMENTO sea igual a GE_NO_COMPROBANTE 
--				Se replica el llenado de GE_DESCRIPCION como en el sp sp_CO_ReporteIntegracionGastosPorSubcontratistaAmatitlan campo DescripcionPartidaServicio
--				Se agrega generación de nombre del reporte para cuando se descarga obtenga el nombre correcto
--				Se deja código comentado por posible reúso en la versión 3 de este reporte
-- =============================================
-- Modificador:	Neri del Angel
-- Fecha:		23 de Marzo del 2023
-- Descripción: Se ajusta que los valores de ID_CATSUBACTIV e ID_ADMON se obtengan de los nuevos campos con el mismo nombre de la tabla CO_LineaPresupuestoMes
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
    DECLARE @Registros INT = 0,
            @Nombre VARCHAR(100) = '424104804GE',
            @Archivo VARCHAR(100) = 'rpt_AmGastosElegibles',
            @Fecha DATE = GETDATE();

    CREATE TABLE #TmpGastosElegibles
    (
        ID_CATACTIV INT NULL,
        ID_CATSUBACTIV INT NULL,
        PR_ANO INT NULL,
        PR_VERSION INT NULL,
        AC_MES INT NULL,
        Actividad INT NULL,
        GE_NO_COMPROBANTE VARCHAR(50),
        GE_MONTO DECIMAL(18, 2),
        GE_REF_DOCUMENTO VARCHAR(50),
        GE_PROVEEDOR VARCHAR(100),
        GE_DESCRIPCION VARCHAR(5000),
        GE_MES INT NULL,
        Etiqueta1 VARCHAR(20),
        IdRegistro INT NULL,
        CvTipoDocFacturacion INT NULL,
        IdFactura INT NULL,
        IdPedimentoComprobante INT NULL,
        IdAceptacionPedidoDetalle INT NULL
    );

    SELECT @Nombre = @Nombre + NombreActividad
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

    DELETE FROM CO_NombreArchivoXtraReport
    WHERE Archivo = @Archivo

    INSERT INTO CO_NombreArchivoXtraReport
    (
        Archivo,
        NombreArchivo
    )
    VALUES
    (@Archivo, @Nombre)

    SELECT @Etiqueta1 = 'ID_ADMINISTRACION'
    WHERE @IdActividad = 1;

    SELECT @Etiqueta1 = 'ID_DUCTO'
    WHERE @IdActividad = 2;

    SELECT @Etiqueta1 = 'ID_ESTUDIO'
    WHERE @IdActividad = 3;

    SELECT @Etiqueta1 = 'ID_INSTALACION'
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
        Etiqueta1,
        IdRegistro,
        CvTipoDocFacturacion,
        IdFactura,
        IdPedimentoComprobante,
        IdAceptacionPedidoDetalle
    )
    SELECT CO_ActividadCIEP.ID_CATACTIV AS ID_CATACTIV,
           CO_LineaPresupuestoMes.ID_CATSUBACTIV AS ID_CATSUBACTIV,
		   --YEAR(CO_LineaPresupuestoMes.AC_FEC_FIN) AS PR_ANO,
           @Anio AS PR_ANO,
		   --ISNULL(CO_Presupuesto.Version, 1) AS PR_VERSION,
           1 AS PR_VERSION,
           @Mes AS AC_MES,
           CO_LineaPresupuestoMes.ID_ADMON AS Actividad,
		   -- ISNULL(CAST(GastosAmatitlan2020.Numero AS VARCHAR(20)), '') AS GE_NO_COMPROBANTE,
           '' AS GE_NO_COMPROBANTE, 
           ISNULL(GastosAmatitlan2020.MontoUSDConMarkup, 0.00) AS GE_MONTO,
           '' AS GE_REF_DOCUMENTO,
		   --ISNULL(CAST(GastosAmatitlan2020.Subcontratista AS VARCHAR(50)), '') AS GE_PROVEEDOR,
           '' AS GE_PROVEEDOR,
           --ISNULL(CAST(GastosAmatitlan2020.Comentarios AS VARCHAR(150)), '') AS GE_DESCRIPCION,
           CASE
               WHEN ISNULL(CO_Registro.DescripcionPartidaServicio, '') = '' THEN
                   ISNULL(CO_Registro.Comentarios, '') COLLATE Modern_Spanish_CI_AS
               ELSE
                   ISNULL(CO_Registro.DescripcionPartidaServicio, '') COLLATE Modern_Spanish_CI_AS
           END AS GE_DESCRIPCION,
		   -- ISNULL(MONTH(CO_RegistroMarkup.MesEstadoPemex), '') AS GE_MES,
           @Mes AS GE_MES,
           @Etiqueta1 AS Etiqueta1,
           CO_Registro.IdRegistro,
           CO_Registro.CvTipoDocFacturacion,
           CO_Registro.IdFactura,
           CO_Registro.IdPedimentoComprobante,
           CO_Registro.IdAceptacionPedidoDetalle
    FROM GastosAmatitlan2020 (NOLOCK)
        JOIN CO_LineaPresupuestoMes (NOLOCK)
            ON GastosAmatitlan2020.LineaPresupuesto = CO_LineaPresupuestoMes.IdLineaPresupuestoMes
        JOIN CO_RegistroMarkup (NOLOCK)
            ON GastosAmatitlan2020.IdRegistro = CO_RegistroMarkup.GastoId
        JOIN CO_ActividadCIEP (NOLOCK)
            ON CO_LineaPresupuestoMes.IdActividad = CO_ActividadCIEP.IdActividad
        JOIN CO_Registro (NOLOCK)
            ON GastosAmatitlan2020.IdRegistro = CO_Registro.IdRegistro
        --LEFT JOIN CO_Instalacion (NOLOCK)
        --    ON CO_LineaPresupuestoMes.IdInstalacion = CO_Instalacion.IdInstalacion
        --LEFT JOIN CO_SubactividadCIEP (NOLOCK)
        --  ON CO_LineaPresupuestoMes.IdSubactividad = CO_SubactividadCIEP.IdSubactividad
        --LEFT JOIN CO_Presupuesto (NOLOCK)
        --    ON CO_LineaPresupuestoMes.IdPresupuesto = CO_Presupuesto.IdPresupuesto
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
    ELSE
    BEGIN
		UPDATE #TmpGastosElegibles
        SET #TmpGastosElegibles.GE_NO_COMPROBANTE = LTRIM(RTRIM(ISNULL(FI_Factura.Serie, '') + ' '
                                                                + ISNULL(FI_Factura.Folio, '')
                                                               )
                                                         ),
            #TmpGastosElegibles.GE_PROVEEDOR = ISNULL(PV_Subcontratista.RazonSocial, '')
        FROM #TmpGastosElegibles            
            JOIN FI_Factura (NOLOCK)
                ON #TmpGastosElegibles.IdFactura = FI_Factura.IdFactura
            JOIN PV_Subcontratista
                ON FI_Factura.IdSubcontratista = PV_Subcontratista.IdSubcontratista

		UPDATE #TmpGastosElegibles
        SET #TmpGastosElegibles.GE_NO_COMPROBANTE = LTRIM(RTRIM(ISNULL(FI_PedimentoComprobante.FolioComprobante, ''))),
            #TmpGastosElegibles.GE_PROVEEDOR = ISNULL(PV_Subcontratista.RazonSocial, '')
        FROM #TmpGastosElegibles 
            JOIN FI_PedimentoComprobante (NOLOCK)
                ON #TmpGastosElegibles.IdPedimentoComprobante = FI_PedimentoComprobante.IdPedimentoComprobante            
            JOIN PV_Subcontratista (NOLOCK)
                ON FI_PedimentoComprobante.IdSubcontratistaExportador = PV_Subcontratista.IdSubcontratista

        UPDATE #TmpGastosElegibles
        SET #TmpGastosElegibles.GE_NO_COMPROBANTE = LTRIM(RTRIM(ISNULL(FI_Factura.Serie, '') + ' '
                                                                + ISNULL(FI_Factura.Folio, '')
                                                               )
                                                         ),
            #TmpGastosElegibles.GE_PROVEEDOR = ISNULL(PV_Subcontratista.RazonSocial, '')
        FROM #TmpGastosElegibles
            JOIN FI_RelacionRefacturas (NOLOCK)
                ON #TmpGastosElegibles.CvTipoDocFacturacion = 1
                   AND #TmpGastosElegibles.IdFactura = FI_RelacionRefacturas.idFacturaHijo
            JOIN FI_Factura (NOLOCK)
                ON FI_RelacionRefacturas.idFacturaPadre = FI_Factura.IdFactura
            JOIN PV_Subcontratista (NOLOCK)
                ON FI_Factura.IdSubcontratista = PV_Subcontratista.IdSubcontratista

        UPDATE #TmpGastosElegibles
        SET #TmpGastosElegibles.GE_NO_COMPROBANTE = LTRIM(RTRIM(ISNULL(FI_Factura.Serie, '') + ' '
                                                                + ISNULL(FI_Factura.Folio, '')
                                                               )
                                                         ),
            #TmpGastosElegibles.GE_PROVEEDOR = ISNULL(PV_Subcontratista.RazonSocial, '')
        FROM #TmpGastosElegibles
            JOIN FI_RelacionPedimento (NOLOCK)
                ON #TmpGastosElegibles.CvTipoDocFacturacion IN ( 2, 3 )
                   AND #TmpGastosElegibles.IdPedimentoComprobante = FI_RelacionPedimento.IdPedimentoHijo
            JOIN FI_Factura (NOLOCK)
                ON FI_RelacionPedimento.idFacturaPadre = FI_Factura.IdFactura
            JOIN PV_Subcontratista (NOLOCK)
                ON FI_Factura.IdSubcontratista = PV_Subcontratista.IdSubcontratista

        UPDATE #TmpGastosElegibles
        SET #TmpGastosElegibles.GE_DESCRIPCION = LTRIM(RTRIM(Petrovendor.dbo.MM_Material.DescripcionLarga COLLATE Modern_Spanish_CI_AS))
        FROM #TmpGastosElegibles
            JOIN Petrovendor.dbo.MM_AceptacionPedidoDetalle (NOLOCK)
                ON #TmpGastosElegibles.IdAceptacionPedidoDetalle = Petrovendor.dbo.MM_AceptacionPedidoDetalle.IdAceptacionPedidoDetalle
            JOIN Petrovendor.dbo.MM_AceptacionPedido (NOLOCK)
                ON Petrovendor.dbo.MM_AceptacionPedidoDetalle.IdAceptacionPedido = Petrovendor.dbo.MM_AceptacionPedido.IdAceptacionPedido
            JOIN Petrovendor.dbo.MM_AceptacionFactura (NOLOCK)
                ON Petrovendor.dbo.MM_AceptacionPedido.IdAceptacionPedido = Petrovendor.dbo.MM_AceptacionFactura.IdAceptacionPedido
            JOIN Petrovendor.dbo.MM_Pedido (NOLOCK)
                ON Petrovendor.dbo.MM_AceptacionPedido.IdPedido = Petrovendor.dbo.MM_Pedido.IdPedido
            JOIN Petrovendor.dbo.MM_Pedidos (NOLOCK)
                ON Petrovendor.dbo.MM_Pedido.IdPedido = Petrovendor.dbo.MM_Pedidos.IdIdentificador
				   -- MERCADEO, ADJ DIRECTA Y COMPRA DIRECTA
                   AND Petrovendor.dbo.MM_Pedidos.IdTipoPedido IN ( 2, 4, 6 )    
                   AND Petrovendor.dbo.MM_Pedidos.IdProveedorCliente = Petrovendor.dbo.MM_Pedido.IdProveedorCompras
            JOIN Petrovendor.dbo.MM_PedidoDetalle (NOLOCK)
                ON Petrovendor.dbo.MM_Pedido.IdPedido = Petrovendor.dbo.MM_PedidoDetalle.IdPedido
                   AND Petrovendor.dbo.MM_AceptacionPedidoDetalle.IdPedidoDetalle = Petrovendor.dbo.MM_PedidoDetalle.IdPedidoDetalle
            JOIN Petrovendor.dbo.MM_PeticionOferta (NOLOCK)
                ON Petrovendor.dbo.MM_Pedido.IdPeticionOferta = Petrovendor.dbo.MM_PeticionOferta.IdPeticionOferta
            JOIN Petrovendor.dbo.MM_PeticionOfertaDetalle (NOLOCK)
                ON Petrovendor.dbo.MM_PeticionOferta.IdPeticionOferta = Petrovendor.dbo.MM_PeticionOfertaDetalle.IdPeticionOferta
                   AND Petrovendor.dbo.MM_PedidoDetalle.IdPeticionOfertaDetalle = Petrovendor.dbo.MM_PeticionOfertaDetalle.IdPeticionOfertaDetalle
            JOIN Petrovendor.dbo.MM_SolicitudPedidoDetalle (NOLOCK)
                ON Petrovendor.dbo.MM_Pedido.IdSolicitudPedido = Petrovendor.dbo.MM_SolicitudPedidoDetalle.IdSolicitudPedido
				   --Producto cotizados en el pedidoy que estan solo en la aceptación
                   AND Petrovendor.dbo.MM_PeticionOfertaDetalle.IdSolicitudPedidoDetalle = Petrovendor.dbo.MM_SolicitudPedidoDetalle.IdSolicitudPedidoDetalle 
            JOIN Petrovendor.dbo.MM_Material (NOLOCK)
                ON Petrovendor.dbo.MM_SolicitudPedidoDetalle.IdMaterial = MM_Material.IdMaterial
                   AND ISNULL(Petrovendor.dbo.MM_Material.DescripcionLarga, '') <> ''
    END

    SELECT ID_CATACTIV,
           ID_CATSUBACTIV,
           PR_ANO,
           PR_VERSION,
           AC_MES,
           Actividad,
           GE_NO_COMPROBANTE,
           GE_MONTO,
           GE_NO_COMPROBANTE AS GE_REF_DOCUMENTO,
           GE_PROVEEDOR,
           GE_DESCRIPCION,
           GE_MES,
           Etiqueta1
    FROM #TmpGastosElegibles
END;