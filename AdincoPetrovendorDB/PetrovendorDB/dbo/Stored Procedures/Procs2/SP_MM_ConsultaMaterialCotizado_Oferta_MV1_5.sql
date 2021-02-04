-- =============================================  
-- Author:           Daniel AC  
-- Create date: 13-08-2019  
-- Description: Agregue validación que si es un Proveedor de CARSO no agregar Marca, Modelo, No Parte a Descripción material  cotizado  
-- =============================================  
-- =============================================  
-- Author:           Daniel AC  
-- Create date: 23-10-2019  
-- Description: Se agrego columnas de día de crédito por partida  
-- =============================================
-- =============================================
-- Author:		Luis David De La Cruz Bautista
-- Create date: 03/02/2021
-- Description:	Optimización por issue 955
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaMaterialCotizado_Oferta_MV1_5] --19435,44,0,0,''  
@IdPeticionOfertaDetalle INT,   
@IdProveedor             INT,   
@IdContrato              INT,   
@IdUsuario               INT,   
@FechaRegistro           DATETIME  
AS  
    BEGIN  
        DECLARE @MATERIALES_ADD_PED FLOAT, 
		@MATERIALES_REQUERIDOS FLOAT, 
		@MATERIALES_EN_APROBACION FLOAT, 
		@MATERIALES_FALTANTES FLOAT, 
		@ID_SPD INT, 
		@PRECIO_UNITARIO_ACTUAL MONEY, 
		@VALIDAR_TIPO_CAMBIO NVARCHAR(150),
		@TIPO_MONEDA_TEXT NVARCHAR(150), 
		@TIPO_MONEDA_ACTUAL INT, 
		@NOMBRE_MATERIAL_SPD NVARCHAR(MAX),
        @ID_MONEDA_DLS INT= 2,  
        @ID_MONEDA_MX INT= 1,
        @EsProveedorDeCARSO INT,
		@FechaActualizacionMateriales DATETIME,
		@VencidaReActivada INT,
        @FechaCotizacionEnviado DATETIME,
		@ESTRELLAS INT= dbo.ObtenerEstrellasModificado(@IdProveedor);
        DECLARE @NOMBRE_MONEDA_DLS VARCHAR(MAX)=  
        (  
            SELECT TipoMonedaCorto  
            FROM PV_TipoMoneda  
            WHERE IdMoneda = @ID_MONEDA_DLS  
        );  
        --VALIDACIÓN CARSO ---   
        CREATE TABLE #ProveedoresCARSO(IdProveedor INT);  
        INSERT INTO #ProveedoresCARSO(IdProveedor)  
        VALUES(650); ---VALOR A EDITAR SEGÚN EL PROVEEDOR CARSO ##EDITAR##  
  
        SELECT @EsProveedorDeCARSO = COUNT(IdProveedor)  
        FROM #ProveedoresCARSO  
        WHERE IdProveedor IN  
        (  
            SELECT SP.IdProveedor  
            FROM dbo.MM_SolicitudPedido SP  
                 INNER JOIN dbo.MM_SolicitudPedidoDetalle SPD (NOLOCk)
					ON SP.IdSolicitudPedido = SPD.IdSolicitudPedido  
				INNER JOIN dbo.MM_PeticionOferta PO (NOLOCk)
					ON SP.IdSolicitudPedido  = PO.IdSolicitudPedido
                 INNER JOIN dbo.MM_PeticionOfertaDetalle POD (NOLOCk)
					ON PO.IdPeticionOferta  = POD.IdPeticionOferta
            WHERE POD.IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle  
            GROUP BY SP.IdProveedor  
        );  
        --FIN VALIDACIÓN CARSO --  
  
        SELECT @FechaCotizacionEnviado = PO.FechaFinalizado  
        FROM dbo.MM_PeticionOferta PO  
             LEFT JOIN dbo.MM_PeticionOfertaDetalle POD (NOLOCk)
				ON PO.IdPeticionOferta = POD.IdPeticionOferta  
        WHERE POD.IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle;  
        SET @VALIDAR_TIPO_CAMBIO = @NOMBRE_MONEDA_DLS;  
        CREATE TABLE #TEMPSTARS(NumeroEstrellas INT NULL
);  
  
        --#TABLA PARA OBTENER CANTIDADES CON ESTATUS DEL MATERIAL  
        CREATE TABLE #CM_ESTATUS  
        (CantidadSolicita                    FLOAT,   
         CantidadPorAgregarPedido            FLOAT,   
         CantidadEnPedidoAprobacion          FLOAT,   
         CantidadEnAprobacionRechazada       FLOAT,   
         CantidadEnConfirmacion              FLOAT,   
         CantidadEnConfirmacionAceptada      FLOAT,   
         CantidadEnConfirmacionRechazada     FLOAT,   
         CantidadEnConfirmacionItemRechazada FLOAT,   
         CantidadPorSolicitar                FLOAT,   
         MaterialSolicitado                  NVARCHAR(MAX),   
         CantidadRecibidaPedidoCerrado       FLOAT  
        );  
        SET @ID_SPD =  
      
  (  
            SELECT SPD.IdSolicitudPedidoDetalle  
            FROM MM_SolicitudPedidoDetalle AS SPD  (NOLOCk)
                 INNER JOIN MM_PeticionOfertaDetalle AS POD (NOLOCk)
					ON SPD.IdSolicitudPedidoDetalle  = POD.IdSolicitudPedidoDetalle
            WHERE POD.IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle  
        );  
        SET @MATERIALES_ADD_PED =  
        (  
            SELECT SUM([AddCantidadTemp])  
            FROM MM_PeticionOfertaDetalle AS POD  
            WHERE POD.IdSolicitudPedidoDetalle
 = @ID_SPD  
                  AND AddPedidoTemp = 1  
                  AND AddValidado = 1  
        );  
        SET @MATERIALES_REQUERIDOS =  
        (  
            SELECT SPD.Cantidad  
            FROM MM_SolicitudPedidoDetalle AS SPD  
          
       INNER JOIN MM_PeticionOfertaDetalle AS POD (NOLOCk)
		ON SPD.IdSolicitudPedidoDetalle  = POD.IdSolicitudPedidoDetalle
            WHERE POD.IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle  
        );  
        SET @MATERIALES_EN_APROBACION = 0;  
       
 INSERT INTO #CM_ESTATUS  
			 
        EXEC SP_MM_ConsultarEstatusCantidadesMaterialSPD_MV1_5   
             @ID_SPD,   
             @IdContrato,   
             @IdUsuario,   
             @FechaRegistro;  
        SET @MATERIALES_FALTANTES =  
      
  (  
            SELECT TOP 1 CantidadPorSolicitar  
            FROM #CM_ESTATUS  
        );  
        SET @NOMBRE_MATERIAL_SPD =  
        (  
            SELECT TOP 1 MaterialSolicitado  
            FROM #CM_ESTATUS  
        );  
  
        --VALIDAR SI LA COTIZACIÓN SE ENVIO ANTES DE ESA FECHA EL PROVEEDOR ENVIO LA COTIZACIÓN DETALLE SIN LA NUEVA MODIFICACIÓN DE TEXTOS MATERIALES   
        
        SELECT @FechaActualizacionMateriales = CONVERT(DATETIME, '2019-09-16 23:59:59.000', 21);-- yyyy-mm-dd hh:mm:ss.mmm ODBC  
  
        IF @EsProveedorDeCARSO = 0  
           AND @FechaActualizacionMateriales > @FechaCotizacionEnviado  
            BEGIN  
                SET @NOMBRE_MATERIAL_SPD =  
     
           (  
                    SELECT M.DescripcionCorta--M.DescripcionCorta  
                    FROM dbo.MM_Material AS M  
                         INNER JOIN dbo.MM_SolicitudPedidoDetalle AS SPD (NOLOCk)
						 ON M.IdMaterial  = SPD.IdMaterial
                
    WHERE SPD.IdSolicitudPedidoDetalle = @ID_SPD  
                );  
        END;  
  
        --- 14 Imagen de Perfil Default  
        SET @PRECIO_UNITARIO_ACTUAL =  
        (  
            SELECT CASE  
                       WHEN POD.IdMoneda <> @ID_MONEDA_DLS  
                       THEN CAST(ROUND(ISNULL(POD.PrecioUnitario, 0) / ISNULL([dbo].[GetTipoCambioActualScalar](POD.IdMoneda, GETDATE()), 0), 2) AS DECIMAL(15, 2))  
                       ELSE POD.PrecioUnitario  
                   END  

            FROM MM_PeticionOfertaDetalle AS POD  
                 INNER JOIN MM_PeticionOferta AS PO (NOLOCk)
					ON POD.IdPeticionOferta  = PO.IdPeticionOferta
            WHERE POD.IdPeticionOfertaDetalle = @IdPeticionOFertaDetalle  
        );  
        SET @TIPO_MONEDA_ACTUAL =  
        (  
            SELECT POD.IdMoneda  
            FROM MM_PeticionOfertaDetalle AS POD  
            WHERE POD.IdPeticionOfertaDetalle = @IdPeticionOFertaDetalle  
        );  
        SET @TIPO_MONEDA_TEXT = @NOMBRE_MONEDA_DLS;  
        IF @TIPO_MONEDA_ACTUAL <> @ID_MONEDA_DLS  
            BEGIN  
                --#Validar que realmente el campo de tipo de cambio tenga un valor si no quiere decir que no se convirtio el precio unitario a DLS  
                SELECT @VALIDAR_TIPO_CAMBIO = CASE  
                                                  WHEN [dbo].[GetTipoCambioActualScalar](POD.IdMoneda, GETDATE()) IS NULL  
                                                  THEN 'TIPO_CAMBIO_NULL'  
                                
                  ELSE 'TIPO_CAMBIO_EXISTE'  
                                              END  
                FROM MM_PeticionOfertaDetalle AS POD  
                     INNER JOIN MM_PeticionOferta AS PO (NOLOCk)
						ON POD.IdPeticionOferta = PO.IdPeticionOferta
 
                WHERE POD.IdPeticionOfertaDetalle = @IdPeticionOFertaDetalle;  
                IF @VALIDAR_TIPO_CAMBIO = 'TIPO_CAMBIO_NULL'  
                    BEGIN  
                        SET @TIPO_MONEDA_TEXT =  
                        (  
    
                        SELECT TM.TipoMonedaCorto  
                            FROM MM_PeticionOfertaDetalle AS POD  
                                 INNER JOIN PV_TipoMoneda TM ON POD.IdMoneda = TM.IdMoneda  
                            WHERE POD.IdPeticionOfertaDetalle = @IdPeticionOFertaDetalle  
                        );  
                END;  
        END;  
  
        --INSERT INTO #TEMPSTARS  EXEC SP_EP_ValoracionEstrellas @IdProveedorEvaluado = @IdProveedor  
        -- DAC COMENTE ESTA FUNCIÓN EL DIA 09/ENERO   
  
        ---SET @ESTRELLAS = (SELECT NumeroEstrellas FROM #TEMPSTARS )  
        -- consulta si este material con cotización vencida se puede agregar  
        IF EXISTS  
        (  
            --SELECT  
            --*  
            --FROM dbo.MM_PeticionOfertaDetalle  
            --WHERE ( DATEDIFF ( MINUTE, FechaVigencia, GETDATE ())) > 0 -- fecha vencida 
 
            --AND ISNULL(AddPedidoTemp,0) > 0 --  que exista un material agregado al pedido  
            --AND IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle  
            SELECT IdHistorialProcesoAbierto  
            FROM dbo.PA_HistorialProcesoAbierto  
            WHERE IdTabla = @IdPeticionOfertaDetalle  
                  AND IdUsuario = @IdUsuario  
        )  
            BEGIN  
                SET @VencidaReActivada = 1;  
        END;  
            ELSE  
            SET @VencidaReActivada = 0;  
  
        ---DONDE DATALENGTH Devuelve el número de bytes utilizados para representar cualquier expresión   
        SELECT POD.IdPeticionOfertaDetalle,  
               CASE  
                   WHEN DATALENGTH(M.Imagen_real) IS NOT NULL  
   
                     AND DATALENGTH(M.Imagen_real) > 0  
                   THEN M.Imagen_real  
                   ELSE  
        (  
            SELECT TOP 1 D.Imagen  
            FROM [dbo].[PV_ImagenPredeterminada] AS D  
            WHERE D.[IdImagenPredeterminada] = 1 --IMAGEN DEFAUL PARA MATERIAL SIN IMAGEN  
        )  
               END AS Imagen,   
               M.DescripcionCorta AS DescripcionCorta,      
               ---CONCAT(M.DescripcionCorta,  
               --  ' Marca: ', CASE WHEN ISNULL(LEN(M.Marca),0)>0 THEN M.Marca ELSE ' S/M' END,  
               --   ' Modelo: ', CASE WHEN ISNULL(LEN(M.Modelo),0)>0 THEN M.Modelo ELSE ' S/M' END,  
               --   ' No. Parte: ',CASE WHEN ISNULL(LEN(M.NumeroParte),0)>0 THEN M.NumeroParte  ELSE ' S/NP' END ) AS DescripcionCorta, ---M.DescripcionCorta,  
               ISNULL(POD.MaterialCotizadoTextoL, 'Sin Detalle') AS DescripcionLarga,   
               ISNULL(POD.FechaVigencia, '') AS FechaVigencia,   
               POD.PrecioUnitario,   
               POD.Disponibilidad,   
               POD.ComentarioSubcontratista,   
               ISNULL(POD.Cotizado, 'false') AS Cotizado,   
               (P.RazonSocial + ' ' + P.RegimenCapital) AS Proveedor,   
               TM.TipoMonedaCorto,   
               ISNULL(POD.AddPedidoTemp, 'false') AS AddPedidoTemp,   
               (CASE  
                    WHEN(DATEDIFF(MINUTE, POD.FechaVigencia, GETDATE())) <= 0  
                    THEN 'false'  
                    ELSE 'true'  
   
             END) AS POD_Vencida,   
               ISNULL(POD.AddCantidadTemp, 0) AS CantidadAgregadaActualmente,   
               SP.AdjudicableParcialmente,   
               PO.IdSubcontratista AS IdProveedor,   
               @MATERIALES_FALTANTES 
AS MaterialesLibres,   
               (CASE  
                    WHEN(@ESTRELLAS > 0)  
                    THEN @ESTRELLAS  
                    ELSE 0  
                END) AS CalificacionProveedor,   
               ISNULL(@PRECIO_UNITARIO_ACTUAL, 0
) AS PRECIO_DLS,   
               @TIPO_MONEDA_TEXT AS MONEDA_TXT,   
               @NOMBRE_MATERIAL_SPD AS NombreMaterialSPD,   
               UM.Unidad,  
               --ISNULL ( condici.DiasCredito, -1 ) AS DiasCredito,   
               ISNULL(POD.DiasCredito, -1) AS DiasCredito,   
               POD.FechaEntrega,   
               ISNULL(CD.CondicionPago, 'No definido') AS CondicionPago,   
               @VencidaReActivada AS VencidaReActivada  
        FROM MM_Material AS M  
             INNER JOIN MM_PeticionOfertaDetalle AS POD (NOLOCk)
				ON M.IdMaterial  = POD.IdMaterialVendedor 
             INNER JOIN MM_PeticionOferta AS PO (NOLOCK)
				ON POD.IdPeticionOferta  = PO.IdPeticionOferta
             INNER JOIN MM_SolicitudPedido AS SP (NOLOCK)
				ON PO.IdSolicitudPedido  = SP.IdSolicitudPedido
             INNER JOIN S_Proveedor AS P (NOLOCK)
				ON PO.IdSubcontratista  = P.IdProveedor
             INNER JOIN PV_TipoMoneda AS TM (NOLOCK)
				ON POD.IdMoneda  = TM.IdMoneda
             LEFT JOIN dbo.PV_MM_MaterialUnidad AS UM (NOLOCK)
				ON POD.IdUnidadProveedor  = UM.IdUnidad
             --LEFT JOIN EP_EvaluacionProveedor AS EP  
             --ON P.IdProveedor = EP.IdProveedorEvaluado  
             LEFT JOIN dbo.PV_ContratistaSubContratista contratista (NOLOCK)
				ON PO.IdSubcontratista  = contratista.IdSubContratista
				AND contratista.IsActivo = 1  
                AND contratista.IdContratista = @IdProveedor  
             LEFT JOIN PV_CondicionesPago condici (NOLOCK)
				ON contratista.IdRelacion  = condici.IdContratistaSubContratista
             LEFT JOIN dbo.MM_CondicionPago CD (NOLOCK)
				ON POD.IdCondicionPago = CD.IdCondicionPago  
        WHERE POD.IdPeticionOfertaDetalle = @IdPeticionOFertaDetalle  
      
        AND POD.IdProveedorVenta = @IdProveedor;  
    END;