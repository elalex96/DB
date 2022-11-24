-- =============================================    
-- Author:  Daniel AC    
-- Create date: 14-02-17    
-- Description: Creación de tabla de comparación de ofertas    
-- =============================================    
-- Author:  Daniel AC    
-- Create date: 04-06-2018    
-- Description: Agregue condición de que no se tome en cuanta los pedido con idestatus = 1 (Eliminados)    
-- =============================================    
-- Author:  Jose Roman    
-- UPDATE date: 19-07-2018    
-- Description: cambio por modificacion al sp "SP_MM_ConsultarEstatusCantidadesMaterialSPD_MV1_5", se agrega una cantidad nueva    
-- =============================================    
-- Author:  Pedro Acuña    
-- UPDATE date: 22-01-2019    
-- Description: se agrega como filtro el contrato    
-- =============================================    
-- =============================================    
-- Author:           Daniel AC    
-- Create date: 13-08-2019    
-- Description: Add Marca, Modelo, No Parte a Descripción material     
-- =============================================    
    
    
CREATE  PROCEDURE [dbo].[SP_MM_ConsultaMaterialesOfertaFinal_V7_MV1_5]    
 -- Add the parameters for the stored procedure here    
 @IdSolicitudPedido INT,    
    @IdContrato    INT,    
    @IdUsuario     INT,    
    @FechaRegistro DATETIME    
    
AS    
BEGIN    
 -- SET NOCOUNT ON added to prevent extra result sets from    
 -- interfering with SELECT statements.    
 SET NOCOUNT ON;    
    
    -- Insert statements for procedure here    
 -- Obtener Materiales --    
 --DROP TABLE #MATERIALES    
 --DROP TABLE #PROVEEDORES    
 --DROP TABLE #MATERIALES_COSTO_MENOR    
     
 --- VARIABLES A UTILIZAR ---    
     
 DECLARE @IsOfertaCotizada bit     
 DECLARE @IsOfertaNoCotizada bit     
 DECLARE @IsMaterialCotizado bit     
 DECLARE @PeticionFinalizada int    
 DECLARE @DISABLED NVARCHAR(60)    
 DECLARE @ICON_VENCIDO NVARCHAR(60) = '<i class="fa fa-calendar-times-o" title="Oferta vencida"></i>'    
 DECLARE @ICON_ADDPEDIDOTEMP NVARCHAR(60)  = '<i class="fa fa-truck" title="Agregado al pedido"></i>'    
 DECLARE @COLOR_PU_COSTO_MENOR NVARCHAR(60) = '#09A542'    
 DECLARE @OFERTA_FINALIZACION_LICITACION DATETIME      
 DECLARE @MOSTRAR_PRECIOS NVARCHAR(200)    
 DECLARE @MATERIALES_EN_POD_ACTUAL  INT     
 DECLARE @PROVEEDORES_EN_POD_ACTUAL INT    
 DECLARE @ROW_MATERIAL INT    
 DECLARE @COLUMN_PROVEEDOR INT     
 DECLARE @ADJUDICACION_PARCIAL BIT     
    DECLARE @TABLA nvarchar(MAX)    
 DECLARE @Cantidad_PO_MejorCosto FLOAT    
 DECLARE @TIPO_SOLICITUD_PEDIDO NVARCHAR(MAX)    
    
 --#VARAIBLES DE CONVERSION DE MONEDA     
 DECLARE @ID_MONEDA_DLS INT = 2  --2 -> DLS  1 --MX     
 DECLARE @ID_MONEDA_MX  INT = 1    
 DECLARE @NOMBRE_MONEDA_DLS  VARCHAR(MAX)=(SELECT TipoMonedaCorto FROM PV_TipoMoneda WHERE IdMoneda= @ID_MONEDA_DLS)     
     
 ----#VALIDAR SI YA EXISTE UNA PETICION OFERTA SI NO SE DEBE CREAR LA TABLA DESDE SOLPED     
    
 SET  @MATERIALES_EN_POD_ACTUAL  = (SELECT COUNT(IdPeticionOferta)    
            FROM MM_PeticionOferta AS PO    
            LEFT JOIN dbo.MM_SolicitudPedido sp ON PO.IdSolicitudPedido = sp.IdSolicitudPedido    
            WHERE PO.IdSolicitudPedido=@IdSolicitudPedido AND sp.IdContrato = @IdContrato)    
    
 SET @ADJUDICACION_PARCIAL  = (SELECT AdjudicableParcialmente FROM MM_SolicitudPedido WHERE IdSolicitudPedido= @IdSolicitudPedido AND IdContrato = @IdContrato)    
     
  --EXECUTE [SP_MM_ActualizarPedidosTemporalesFechaVigenciaOferta]  @IdSolicitudPedido    
    
  SET @TIPO_SOLICITUD_PEDIDO = (SELECT TSP.TipoSolicitudPedido FROM dbo.MM_SolicitudPedido AS SP    
         INNER JOIN dbo.MM_TipoSolicitudPedido AS TSP ON TSP.IdTipoSolicitudPedido=SP.IdTipoSolicitudPedido    
         WHERE SP.IdSolicitudPedido=@IdSolicitudPedido AND SP.IdContrato = @IdContrato)    
  IF @MATERIALES_EN_POD_ACTUAL  = 0  --- IF 1     
  BEGIN -----------------------------INICIO CONDICION 1-------------------------------    
        
    ------- GENERAR TABLA COMPARATIVA CON SOLO LOS MATERIALES OBTENIENDO LA INFORMACIÓN DESDE MM_SOLICITUDPEDIDO Y MM_SOLICITUDPEDIDODETALLE    
   --DROP TABLE #PROVEEDORES    
   CREATE TABLE #MATERIALES_SPD(IdRow int,IdMaterial int,NombreMaterial nvarchar(MAX),ComentarioComprador nvarchar(MAX), NoMaterialesRequeridos int, IdSolicitudPedidoDetalle int)    
       
   INSERT INTO #MATERIALES_SPD     
   SELECT  ROW_NUMBER() OVER(ORDER BY SPD.IdMaterial ASC) AS Row#,(SPD.IdMaterial),    
   CONCAT (MM.DescripcionCorta,    
            ' Marca: ', CASE WHEN ISNULL(LEN(MM.Marca),0)>0 THEN MM.Marca ELSE ' S/M' END,    
            ' Modelo: ', CASE WHEN ISNULL(LEN(MM.Modelo),0)>0 THEN MM.Modelo ELSE ' S/M' END,    
            ' No. Parte: ',CASE WHEN ISNULL(LEN(MM.NumeroParte),0)>0 THEN MM.NumeroParte  ELSE ' S/NP' END) AS DescripcionCorta,--MM.DescripcionCorta,    
   SPD.observaciones,SPD.Cantidad, SPD.IdSolicitudPedidoDetalle    
   FROM MM_SolicitudPedidoDetalle AS SPD    
   INNER JOIN MM_Material AS MM ON MM.IdMaterial = SPD.IdMaterial     
   INNER JOIN MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = SPD.IdSolicitudPedido    
   WHERE SP.IdSolicitudPedido = @IdSolicitudPedido AND SP.IdContrato = @IdContrato    
   GROUP BY SPD.IdMaterial,  MM.DescripcionCorta, SPD.observaciones, SPD.Cantidad, SPD.IdSolicitudPedidoDetalle, MM.Marca, MM.Modelo, MM.NumeroParte    
   ORDER BY  MM.DescripcionCorta ASC    
    
   --- Obtener Proveedores ---       
    --- No se visializan proveedores por que no hay ninguna peticion oferta    
    
      --- Declarar Columnas y Filas Indicadores ---    
    
    SET @ROW_MATERIAL  =1    
    SET @COLUMN_PROVEEDOR  = 1         
      
    --- Hacer Cabecera de la Tabla ---    
    
    SET @TABLA = '<table class="table table-flip-scroll cf table-bordered" style="cursor: pointer"  id="tb_ofertas"  data-materiales="'+CAST((SELECT COUNT(IdMaterial) FROM #MATERIALES_SPD) AS NVARCHAR(MAX))+'">'    
    SET @TABLA = @TABLA+'<thead class="cf">'    
     
    SET @TABLA = @TABLA + '<tr>'    
    SET @TABLA = @TABLA+'<th width="400px;">'+ISNULL(@TIPO_SOLICITUD_PEDIDO,'MATERIAL')+'</th>'    
    SET @TABLA = @TABLA+'<th width="100px;">Cantidad</th>'     
    SET @TABLA = @TABLA+'<th width="100px;">Proveedores</th>'     
     
    --- Agregar Columnas cabeceras de los Proveedores ofertados ---    
          
    
    SET @TABLA = @TABLA + '</tr>'    
    SET @TABLA = @TABLA+'</thead>'    
    
        
    ----Agregar detalle de los materiales que se mandaron a cotizar     
    
     WHILE @ROW_MATERIAL <= (SELECT COUNT(IdMaterial) FROM #MATERIALES_SPD)    
     BEGIN    
        
      SET @TABLA = @TABLA+'<tr id="Material_'+CAST(@ROW_MATERIAL AS NVARCHAR(MAX))+'" data-material = "'+CAST((SELECT IdMaterial FROM #MATERIALES_SPD WHERE IdRow = @ROW_MATERIAL) AS NVARCHAR(MAX))+'"'    
      SET @TABLA = @TABLA+' data-spd = "'+CAST((SELECT IdSolicitudPedidoDetalle FROM #MATERIALES_SPD WHERE IdRow = @ROW_MATERIAL) AS NVARCHAR(MAX))+'">'    
      --- Columna Material Ofertados ---    
      SET @TABLA = @TABLA+'<td><b>'    
      SET @TABLA = @TABLA+ (SELECT NombreMaterial FROM #MATERIALES_SPD WHERE IdRow =@ROW_MATERIAL)    
      SET @TABLA = @TABLA+'</b><br><br>'    
      SET @TABLA = @TABLA+ (SELECT ComentarioComprador FROM #MATERIALES_SPD WHERE IdRow =@ROW_MATERIAL)    
      SET @TABLA = @TABLA+'</td>'    
    
         
      --- Columna Cantidad Requerida  ---    
      SET @TABLA = @TABLA+'<td>'    
      SET @TABLA =CONCAT(@TABLA, (SELECT NoMaterialesRequeridos FROM #MATERIALES_SPD WHERE IdRow =@ROW_MATERIAL))           
      SET @TABLA = @TABLA+'</td>'    
      
     ------- VALIDAR EL PRECIO MAS BAJO SEGUN EL MATERIAL ---    
    
       ---INSERT INTO #MATERIALES_COSTO_MENOR    
     IF @ROW_MATERIAL = 1    
     BEGIN        
    
      SET @TABLA = @TABLA+'<td rowspan="'+CAST((SELECT COUNT(IdMaterial) FROM #MATERIALES_SPD) AS NVARCHAR(MAX))+'" style="text-align:center;">'    
      SET @TABLA = @TABLA+'Ningún proveedor invitado a recuperado la cotización'    
      SET @TABLA = @TABLA+'</td>'         
     END     
     SET @TABLA = @TABLA+'</tr>'     
     SET @ROW_MATERIAL = @ROW_MATERIAL + 1    
   END     
       
  SET @TABLA = @TABLA+'</td>'    
  SET @TABLA = @TABLA+'</tbody>'    
  SET @TABLA = @TABLA+'</table>'    
    
    -----------------------------FIN CONDICION 1-------------------------------    
    
  END    
    
  ELSE     
    ------------------ INICIO CONDICION 2 -----------------------------------------    
  --- #GENERAR TABLA COMPARATIVA CON LOS MATERIALES Y PROVEEDORES CORRESPONDIENTES    
  --- #Para llegar a este punto quiere decir que existe más de un proveedor en IdPeticionOferta con la IdSolicitudPedido Actual    
  BEGIN      
  --- Validar si la oferta ya genero un pedido     
    
  SET @OFERTA_FINALIZACION_LICITACION = (     
  SELECT ISNULL(TAO.FechaFinalizacion,getDATE()) As FechaLimite    
  FROM MM_SolicitudPedido AS SP    
  INNER JOIN TA_Operacion AS TAO ON TAO.IdDocumento = SP.IdSolicitudPedido    
  INNER JOIN TA_Vencimiento AS V ON V.IdVencimiento = TAO.IdVigencia    
  INNER JOIN S_Proveedor AS PR ON PR.IdProveedor = SP.IdProveedor    
  WHERE SP.IdSolicitudPedido =@IdSolicitudPedido AND IdTipoOperacion = 6)     
      
  SET @MOSTRAR_PRECIOS =(SELECT (( case  when  (DATEDIFF(MINUTE,@OFERTA_FINALIZACION_LICITACION, GETDATE()))  <= 0 then  'NO' ELSE 'SI' END )))    
    
     
  SET @PeticionFinalizada = (SELECT COUNT(IdPedido) FROM MM_Pedido P WHERE P.IdSolicitudPedido = @IdSolicitudPedido AND ISNULL(P.IdEstatusEliminado,0)<>1 )--> PEDIDO NO ESTE ELIMINADO    
     
  IF @PeticionFinalizada > 0     
   SET @DISABLED = 'disabled'    
  ELSE    
   SET @DISABLED = ''    
    
  CREATE TABLE #MATERIALES(IdRow int,IdMaterial int,NombreMaterial nvarchar(MAX),ComentarioComprador nvarchar(MAX), NoMaterialesRequeridos float, IdSolicitudPedidoDetalle int)    
  CREATE TABLE #PROVEEDORES(IdRow int, NombreProveedor nvarchar(MAX),IdProveedor int, RCF nvarchar(MAX), IdPeticionOferta int, MejorOferta bit, PrecioTotal float)    
  CREATE TABLE #MATERIALES_COSTO_MENOR(IdProveedor int, PrecioTotal float)    
  CREATE TABLE #MATERIALES_COSTO_MENOR_DLS(IdProveedor int, PrecioTotal float)    
  CREATE TABLE #CM_ESTATUS(CantidadSolicita FLOAT,     
        CantidadPorAgregarPedido FLOAT,     
        CantidadEnPedidoAprobacion FLOAT,     
        CantidadEnAprobacionRechazada FLOAT,     
        CantidadEnConfirmacion FLOAT,     
        CantidadEnConfirmacionAceptada FLOAT,    
        CantidadEnConfirmacionRechazada FLOAT,    
        CantidadEnConfirmacionItemRechazada FLOAT,    
        CantidadPorSolicitar FLOAT,    
        MaterialSolicitado NVARCHAR(MAX),    
        CantidadRecibidaPedidoCerrado FLOAT
        )    
    
  ---#OBTENER LOS TIPOS DE CAMBIOS DE ACUERDO A LA FECHA ACTUAL    
  CREATE TABLE #TIPO_CAMBIO(TipoCambio DECIMAL(12,4),Fecha datetime, IdMoneda int)    
  INSERT INTO  #TIPO_CAMBIO  ---    
  SELECT  [dbo].[GetTipoCambioActualScalar](POD.IdMoneda, GETDATE()),GETDATE(), POD.IdMoneda    
  FROM dbo.MM_PeticionOfertaDetalle POD     
  INNER JOIN dbo.MM_PeticionOferta AS PO ON PO.IdPeticionOferta=POD.IdPeticionOferta    
  WHERE PO.IdSolicitudPedido =@IdSolicitudPedido AND PO.Cotizado IS NOT NULL AND POD.IdMoneda IS NOT NULL    
  GROUP BY  [dbo].[GetTipoCambioActualScalar](POD.IdMoneda, GETDATE()), POD.IdMoneda    
  ORDER BY POD.IdMoneda ASC    
      
  --drop table #MATERIALES    
  --drop table #PROVEEDORES    
  --drop table #MATERIALES_COSTO_MENOR    
  --drop table #MATERIALES_COSTO_MENOR_DLS    
   --- Obtener Materiales ----    
  INSERT INTO #MATERIALES     
  SELECT  ROW_NUMBER() OVER(ORDER BY POD.IdMaterial ASC) AS Row#,(POD.IdMaterial) ,    
  CONCAT (MM.DescripcionCorta,    
            ' Marca: ', CASE WHEN ISNULL(LEN(MM.Marca),0)>0 THEN MM.Marca ELSE ' S/M' END,    
            ' Modelo: ', CASE WHEN ISNULL(LEN(MM.Modelo),0)>0 THEN MM.Modelo ELSE ' S/M' END,    
            ' No. Parte: ',CASE WHEN ISNULL(LEN(MM.NumeroParte),0)>0 THEN MM.NumeroParte  ELSE ' S/NP' END) AS DescripcionCorta, --MM.DescripcionCorta,    
  POD.ComentariosComprador,POD.NoMaterialesRequeridos, POD.IdSolicitudPedidoDetalle    
  FROM MM_PeticionOfertaDetalle AS POD    
  INNER JOIN dbo.MM_Material AS MM ON MM.IdMaterial = POD.IdMaterial     
  INNER JOIN MM_PeticionOferta AS PO ON PO.IdPeticionOferta= POD.IdPeticionOferta    
  INNER JOIN MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = PO.IdSolicitudPedido    
  WHERE SP.IdSolicitudPedido = @IdSolicitudPedido    
  GROUP BY POD.IdMaterial,  MM.DescripcionCorta, pod.ComentariosComprador, POD.NoMaterialesRequeridos, POD.IdSolicitudPedidoDetalle,MM.Marca, MM.Modelo, MM.NumeroParte    
  ORDER BY  MM.DescripcionCorta ASC    
    
  --- Obtener Proveedores ---    
    
   INSERT INTO #PROVEEDORES    
   SELECT ROW_NUMBER() OVER(ORDER BY P.IdProveedor ASC) AS Row#, ISNULL(P.RazonSocial,'') +' '+ ISNULL(P.RegimenCapital,'') AS Razonsocial,  P.IdProveedor,RFC, PO.IdPeticionOferta,0,0    
   FROM MM_PeticionOferta PO    
   INNER JOIN MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = PO.IdSolicitudPedido    
   INNER JOIN S_Proveedor AS P ON P.IdProveedor= PO.IdSubcontratista    
   WHERE SP.IdSolicitudPedido =@IdSolicitudPedido    
   ORDER BY P.Razonsocial    
         
   --- Declarar Columnas y Filas Indicadores ---    
    
   SET @ROW_MATERIAL  =1    
   SET @COLUMN_PROVEEDOR  = 1    
         
   --- Hacer Cabecera de la Tabla por la cantidad de proveedores ---    
    
  SET @TABLA = '<table class="table table-flip-scroll cf table-bordered" style="cursor: pointer"  id="tb_ofertas"  data-materiales="'+CAST((SELECT COUNT(IdMaterial) FROM #MATERIALES) AS NVARCHAR(MAX))+'">'    
  SET @TABLA = @TABLA+'<thead class="cf">'    
     
  SET @TABLA = @TABLA + '<tr>'    
  SET @TABLA = @TABLA+'<th width="400px;">'+ISNULL(@TIPO_SOLICITUD_PEDIDO,'MATERIAL')+'</th>'    
  SET @TABLA = @TABLA+'<th width="100px;">Cantidad</th>'     
     
  --- Agregar Columnas cabeceras de los Proveedores ofertados ---    
    
  WHILE @COLUMN_PROVEEDOR <=(SELECT COUNT(IdProveedor) FROM #PROVEEDORES)     
    
   BEGIN     
    
   DECLARE @IdPROVEEDOR INT = (SELECT IdProveedor FROM #PROVEEDORES WHERE IdRow = @COLUMN_PROVEEDOR)    
   DECLARE @IdCotizacion INT = (SELECT IdPeticionOferta FROM #PROVEEDORES WHERE IdRow = @COLUMN_PROVEEDOR)    
    
    SET @TABLA = @TABLA + '<th width="500px;" style="text-align: -webkit-center;" class="prov" data-prov="'+CAST(@IdPROVEEDOR AS nvarchar(50))+'" title="Cotización No.'+CAST(@IdCotizacion AS nvarchar(50))+'">'     
    SET @TABLA =  @TABLA+(SELECT NombreProveedor FROM #PROVEEDORES WHERE IdRow = @COLUMN_PROVEEDOR)    
    SET @TABLA = @TABLA + '</th>'    
    SET @COLUMN_PROVEEDOR = @COLUMN_PROVEEDOR + 1    
   END     
    
  SET @TABLA = @TABLA + '</tr>'    
  SET @TABLA = @TABLA+'</thead>'    
    
     
     
  --- HACER CUERPO TABLA ---    
  --- RECORRER CADA MATERIAL     
  --- POR CADA MATERIAL SE RECORRE CADA PROVEDOR PARA CONSULTAR LOS DATOS DE COTIZACION MATERIAL EN TURNO    
  --- SE VALIDA  LOS PRECIOS MAS BAJOS Y SE ACTUALIZA EL CAMPO  CostoMenor    
     
    
  SET @TABLA = @TABLA+'<tbody>'    
    
    
  IF @ADJUDICACION_PARCIAL = 0  --- OBTENER AL PROVEEDOR CON EL MEJOR PRECIO      
   BEGIN     
    --# IdMoneda 2 = DLS    
    --# IdMoneda 1 = MX    
    --# Se realiza JOIN Externo con [Adinco].[dbo].[CO_TipoCambioDiario] para obtener el tipo de cambio actual    
    
    INSERT INTO #MATERIALES_COSTO_MENOR    
    SELECT PR.IdProveedor,     
     CASE WHEN POD.IdMoneda <> @ID_MONEDA_DLS THEN      
      SUM( ISNULL(((ISNULL(POD.PrecioUnitario,0)/ISNULL(TC.TipoCambio,1))*Disponibilidad),0))         
     ELSE      
       SUM( ISNULL((POD.PrecioUnitario*Disponibilidad),0))  END AS MENOR_PRECIO --,    
      --POD.PrecioUnitario , POD.IdMoneda , Disponibilidad , TCD.TipoCambio , PO.FechaFinalizado       
    FROM S_Proveedor AS PR    
    INNER JOIN #PROVEEDORES AS PV ON PV.IdProveedor = PR.IdProveedor    
    INNER JOIN MM_PeticionOferta AS PO ON PO.IdSubcontratista = PR.IdProveedor    
    INNER JOIN MM_PeticionOfertaDetalle AS POD ON  POD.IdPeticionOferta = PO.[IdPeticionOferta]        
    LEFT JOIN #TIPO_CAMBIO AS TC ON TC.IdMoneda= POD.IdMoneda     
    WHERE PO.IdSolicitudPedido = @IdSolicitudPedido AND PO.COTIZADO = 1 AND POD.Cotizado = 1 ---@IdSolicitudPedido    
    AND PR.IdProveedor NOT IN  (SELECT  IdProveedor    
          FROM S_Proveedor AS PR     
          INNER JOIN MM_PeticionOferta AS PO ON PO.IdSubcontratista = PR.IdProveedor    
          INNER JOIN MM_PeticionOfertaDetalle AS POD ON  POD.IdPeticionOferta = PO.[IdPeticionOferta]    
          WHERE PO.IdSolicitudPedido =@IdSolicitudPedido   AND PO.COTIZADO =1 AND ISNULL(POD.Cotizado,0) = 0 ----@IdSolicitudPedido    
          GROUP BY IdProveedor)     
    GROUP BY PR.IdProveedor , POD.IdMoneda---,POD.PrecioUnitario  ,POD.IdMoneda ,Disponibilidad ,TCD.TipoCambio ,PO.FechaFinalizado    
    ORDER BY MENOR_PRECIO, PR.IdProveedor  ASC    
    
    ---Obtener la suma del todo el total con precios en DLS    
    INSERT INTO #MATERIALES_COSTO_MENOR_DLS    
    SELECT IdProveedor,SUM(PrecioTotal)    
    FROM #MATERIALES_COSTO_MENOR    
    GROUP BY IdProveedor    
        
    
    SET @Cantidad_PO_MejorCosto = (SELECT MIN(PrecioTotal)    
                FROM #MATERIALES_COSTO_MENOR_DLS)    
    
        
    UPDATE PV SET MejorOferta = 1    
    FROM #MATERIALES_COSTO_MENOR_DLS AS PR     
    INNER JOIN #PROVEEDORES AS PV ON PV.IdProveedor = PR.IdProveedor    
    WHERE PR.PrecioTotal = @Cantidad_PO_MejorCosto     
    
   END     
    
  --- Se recorren todos los MATERIALES ---    
    
   WHILE @ROW_MATERIAL <= (SELECT COUNT(IdMaterial) FROM #MATERIALES)    
   BEGIN    
        
    DECLARE @DATA_MATERIAL NVARCHAR(350) = CAST((SELECT IdMaterial FROM #MATERIALES WHERE IdRow = @ROW_MATERIAL) AS NVARCHAR(MAX))    
    DECLARE @DATA_ID_SPD NVARCHAR(350) =CAST((SELECT IdSolicitudPedidoDetalle FROM #MATERIALES WHERE IdRow = @ROW_MATERIAL) AS NVARCHAR(MAX))    
    
    SET @TABLA = @TABLA+'<tr id="Material_'+CAST(@ROW_MATERIAL AS NVARCHAR(MAX))+'">'    
       
    --- Columna Material Ofertados ---    
    SET @TABLA = @TABLA+'<td class="item_material_spd" data-material = "'+@DATA_MATERIAL+'" data-spd="'+@DATA_ID_SPD+'"><b>'    
    SET @TABLA = @TABLA+ (SELECT NombreMaterial FROM #MATERIALES WHERE IdRow =@ROW_MATERIAL)    
    SET @TABLA = @TABLA+'</b><br><br>'    
    ---SET @TABLA = @TABLA+ (SELECT ComentarioComprador FROM #MATERIALES WHERE IdRow =@ROW_MATERIAL)    
    SET @TABLA = @TABLA+'</td>'    
    
         
    DELETE FROM #CM_ESTATUS    
        
    DECLARE @ICON_MATERIALES_YA_SOLICITADOS NVARCHAR(MAX)     
    DECLARE @MATERIALES_FALTANTES FLOAT = 0    
    DECLARE @ID_SPD_MM INT = 0    
    
     --- REVISAR DISPONIBILIDAD DE MATERIALES    
   SET @ID_SPD_MM =(SELECT IdSolicitudPedidoDetalle FROM #MATERIALES WHERE IdRow =@ROW_MATERIAL)    
   INSERT INTO #CM_ESTATUS    
   EXEC SP_MM_ConsultarEstatusCantidadesMaterialSPD_MV1_5 @ID_SPD_MM,@IdContrato, @IdUsuario,@FechaRegistro    
    
   SET @MATERIALES_FALTANTES = (SELECT TOP 1 ISNULL(CantidadPorSolicitar,0) FROM #CM_ESTATUS)    
         
   IF @MATERIALES_FALTANTES = 0    
    BEGIN    
     SET @ICON_MATERIALES_YA_SOLICITADOS = ' <i class="fa fa-check-circle-o" title="Cantidad de unidades de materiales/servicios  ya solitados en su totalidad."></i> '    
    END    
   ELSE    
    BEGIN    
     SET @ICON_MATERIALES_YA_SOLICITADOS = ''    
    END    
    --- Columna Cantidad Requerida  ---    
    SET @TABLA = @TABLA+'<td class="item_cantidad_spd" data-spd="'+@DATA_ID_SPD+'" style="text-align: right;">'    
    SET @TABLA =CONCAT(@TABLA, (SELECT NoMaterialesRequeridos FROM #MATERIALES WHERE IdRow =@ROW_MATERIAL))    
    SET @TABLA = @TABLA + @ICON_MATERIALES_YA_SOLICITADOS    
    SET @TABLA = @TABLA+'</td>'    
      
   ------- VALIDAR EL PRECIO MAS BAJO SEGUN EL MATERIAL ---    
    
        
     ---INSERT INTO #MATERIALES_COSTO_MENOR    
      DECLARE @Cantidad_PU_MejorCosto FLOAT    
    
      IF @ADJUDICACION_PARCIAL = 1    
      BEGIN     
         
    
     --- OBTERNER PRECIO MAS BAJO del MATERIAL EN DLS     
     ---# IdMoneda = 1 MX    
         
     SET @Cantidad_PU_MejorCosto = (SELECT MIN(CASE WHEN POD.IdMoneda <> @ID_MONEDA_DLS THEN     
               ISNULL(POD.PrecioUnitario,0)/ISNULL(TC.TipoCambio,1)    
              ELSE     
               POD.PrecioUnitario    
              END)    
               FROM MM_PeticionOfertaDetalle AS POD    
               INNER JOIN MM_PeticionOferta AS PO ON PO.IdPeticionOferta = POD.IdPeticionOferta    
               INNER JOIN MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido  = PO.IdSolicitudPedido    
               LEFT JOIN #TIPO_CAMBIO AS TC ON TC.IdMoneda= POD.IdMoneda      
               WHERE SP.IdSolicitudPedido = @IdSolicitudPedido      
               AND POD.IdSolicitudPedidoDetalle= (SELECT IdSolicitudPedidoDetalle    
                FROM #MATERIALES    
                WHERE IdROW=@ROW_MATERIAL)     
              AND Preciounitario <> 0    
              AND POD.Cotizado = 1)    
    END          
    
    
    
   --- Agregar Datos de la petición de Oferta Detalle por Proveedor y material Actual---    
    
       
   SET @COLUMN_PROVEEDOR = 1    
   WHILE @COLUMN_PROVEEDOR <= (SELECT COUNT(IdProveedor) FROM #PROVEEDORES)     
    
   BEGIN     
    
    --- VALIDAR SI EL PROVEEDOR TIENE PRECIO MENOR COSTO AGREGAR UN BACKGROUP COLOR ---    
    --- OBTENER EL PRECIO UNITARIO DEL MATERIAL Y PROVEEDOR ACTUAL ---    
    
    
    DECLARE @PRECIO_UNITARIO_ACTUAL FLOAT    
    DECLARE @ID_POD INT     
    DECLARE @CANTIDAD_DISPONIBLE FLOAT     
    DECLARE @COMENTARIO_PROVEEDOR NVARCHAR(MAX)    
    DECLARE @ADDLISTAPEDIDO BIT    
    DECLARE @POD_COTIZADO BIT    
    DECLARE @ADD_CANTIDADTEMP FLOAT    
    DECLARE @OFERTA_VENCIDA BIT    
    DECLARE @TIPO_MONEDA_TEXT NVARCHAR(MAX)  = @NOMBRE_MONEDA_DLS    
    DECLARE @VALIDAR_TIPO_CAMBIO NVARCHAR(150)    
    DECLARE @TIPO_MONEDA_ACTUAL INT     
        
             
    SET  @ID_POD =  (SELECT POD.IdPeticionOfertaDetalle     
         FROM MM_PeticionOfertaDetalle AS POD    
         INNER  JOIN #PROVEEDORES AS PT ON PT.IdPeticionOferta = POD.IdPeticionOferta     
         INNER JOIN #MATERIALES AS MT ON MT.IdSolicitudPedidoDetalle = POD.IdSolicitudPedidoDetalle    
         WHERE PT.IdRow = @COLUMN_PROVEEDOR  AND MT.IdROW= @ROW_MATERIAL     
         AND  POD.IdProveedorVenta = PT.IdProveedor               
          )    
    
     --## Conversión a Moneda DLS    
    
      SET @PRECIO_UNITARIO_ACTUAL = (SELECT CASE WHEN POD.IdMoneda <> @ID_MONEDA_DLS THEN     
               ISNULL(POD.PrecioUnitario,0)/ISNULL(TC.TipoCambio,1)    
              ELSE     
               POD.PrecioUnitario    
              END     
            FROM MM_PeticionOfertaDetalle AS POD    
            INNER JOIN MM_PeticionOferta AS PO ON PO.IdPeticionOferta = POD.IdPeticionOferta    
            LEFT JOIN #TIPO_CAMBIO AS TC ON TC.IdMoneda= POD.IdMoneda    
            WHERE POD.IdPeticionOfertaDetalle = @ID_POD)    
    
      SET @TIPO_MONEDA_ACTUAL = (SELECT  POD.IdMoneda     
            FROM MM_PeticionOfertaDetalle AS POD    
            WHERE POD.IdPeticionOfertaDetalle = @ID_POD)    
                
      IF @TIPO_MONEDA_ACTUAL <> @ID_MONEDA_DLS    
      BEGIN     
       --#Validar que realmente el campo de tipo de cambio tenga un valor si no quiere decir que no se convirtio el precio unitario a DLS    
       SELECT @VALIDAR_TIPO_CAMBIO = CASE WHEN TC.TipoCambio IS NULL THEN     
           'TIPO_CAMBIO_NULL'    
         ELSE     
           'TIPO_CAMBIO_EXISTE'    
         END     
       FROM MM_PeticionOfertaDetalle AS POD    
       INNER JOIN MM_PeticionOferta AS PO ON PO.IdPeticionOferta = POD.IdPeticionOferta    
       LEFT JOIN #TIPO_CAMBIO AS TC ON TC.IdMoneda= POD.IdMoneda     
       WHERE POD.IdPeticionOfertaDetalle = @ID_POD    
    
                  
       IF @VALIDAR_TIPO_CAMBIO = 'TIPO_CAMBIO_NULL'    
        BEGIN    
         SET @TIPO_MONEDA_TEXT = (SELECT TM.TipoMonedaCorto    
              FROM MM_PeticionOfertaDetalle AS POD    
              INNER JOIN PV_TipoMoneda TM ON POD.IdMoneda = TM.IdMoneda    
              WHERE  POD.IdPeticionOfertaDetalle = @ID_POD)    
        END     
      END     
           
    
          
    
      SET @CANTIDAD_DISPONIBLE = (SELECT Disponibilidad     
            FROM MM_PeticionOfertaDetalle AS POD    
            WHERE POD.IdPeticionOfertaDetalle = @ID_POD)    
    
    
      SET @COMENTARIO_PROVEEDOR = (SELECT ComentarioSubcontratista     
            FROM MM_PeticionOfertaDetalle AS POD    
            WHERE POD.IdPeticionOfertaDetalle = @ID_POD)    
    
      SET @ADDLISTAPEDIDO = (SELECT  AddPedidoTemp    
            FROM MM_PeticionOfertaDetalle AS POD    
            WHERE POD.IdPeticionOfertaDetalle = @ID_POD)    
       
      SET @ADD_CANTIDADTEMP = (SELECT  ISNULL(AddCantidadTemp,0)    
          FROM MM_PeticionOfertaDetalle AS POD    
          WHERE POD.IdPeticionOfertaDetalle = @ID_POD)    
    
      SET @OFERTA_VENCIDA = (SELECT( case  when  (DATEDIFF(MINUTE,POD.FechaVigencia, GETDATE()))  <= 0 then  'false' ELSE 'true' END  ) AS POD_Vencida    
          FROM MM_PeticionOfertaDetalle AS POD    
          WHERE POD.IdPeticionOfertaDetalle = @ID_POD)    
    
    
     DECLARE @IdProveedorActual int     
     DECLARE @MejorOferta bit      
        
    
     SET @IdProveedorActual   = (SELECT IdProveedor     
            FROM #PROVEEDORES     
            WHERE IdRow = @COLUMN_PROVEEDOR)    
     SET @MejorOferta = (SELECT MejorOferta     
            FROM #PROVEEDORES     
            WHERE IdRow = @COLUMN_PROVEEDOR)    
    
    --- VALIDAR OFERTA ESTE EN ESTATUS APROBADO PARA PODER MOSTRAR LOS PRECIOS UNITARIOS ---    
       
    SET @IsOfertaCotizada = (SELECT ISNULL(Cotizado,'false') AS PeticionCotizada          
           FROM MM_PeticionOferta AS PO    
           INNER JOIN #PROVEEDORES AS PT ON PT.IdProveedor =PO.IdSubcontratista    
           WHERE PT.IdRow = @COLUMN_PROVEEDOR      
          AND PO.IdSolicitudPedido = @IdSolicitudPedido    
          AND PO.IdPeticionOferta = PT.IdPeticionOferta                    
          )    
    SET @IsOfertaNoCotizada = (SELECT NoCotizar AS PeticionNoCotizada          
           FROM MM_PeticionOferta AS PO    
           INNER JOIN #PROVEEDORES AS PT ON PT.IdProveedor =PO.IdSubcontratista    
           WHERE PT.IdRow = @COLUMN_PROVEEDOR      
          AND PO.IdSolicitudPedido = @IdSolicitudPedido    
          AND PO.IdPeticionOferta = PT.IdPeticionOferta    
          )    
    
    IF @MOSTRAR_PRECIOS = 'SI'    
     BEGIN    
     --- #VALIDAR SI LA OFERTA ESTA COTIZADA ENTONCES MOSTRAR PRECIOS UNITARIOS ---    
     IF @IsOfertaCotizada = 1      
      BEGIN     
           
      --- VALIDAR SI LA PETICION OFERTA DETALLE ESTA COTIZADA     
    
      SET @IsMaterialCotizado  =  (SELECT  ISNULL(Cotizado,0)    
          FROM MM_PeticionOfertaDetalle AS POD    
          WHERE POD.IdPeticionOfertaDetalle = @ID_POD)    
          
                
      IF @IsMaterialCotizado = 1     
       BEGIN     
             ---# VALIDACIONES DE MATERIALES/SERVICIOS COTIZADOS     
             DECLARE @ETIQUETA_MENOR NVARCHAR(200)    
             
           
         ----  OBTENER INFORMACION DEL MATERIAL COTIZADO  ----    
    
         --- #VALIDAR SI MATERIAL ES IGUAL AL MEJOR COSTO ---    
            
         IF @PRECIO_UNITARIO_ACTUAL = @Cantidad_PU_MejorCosto  OR @MejorOferta = 1    
    
          BEGIN    
           SET @TABLA = @TABLA + '<td class="item_peticion" bgcolor="'+@COLOR_PU_COSTO_MENOR+'" style="text-align:center" data-idPOD="'+CAST(@ID_POD AS nvarchar(50))+'" data-Proveedor="'+CAST(@IdProveedorActual AS nvarchar(50))+'"  title="Precio Unitario 
 
 del Material/Servicio. Seleccione para ver más detalles">'     
           SET @ETIQUETA_MENOR = ''----'<span class="label label-success">Menor Costo</span>'    
          END     
    
         ELSE    
    
          BEGIN    
           SET @TABLA = @TABLA + '<td class="item_peticion" data-idPOD="'+CAST(@ID_POD AS nvarchar(50))+'"  style="text-align:center"  data-Proveedor="'+CAST(@IdProveedorActual AS nvarchar(50))+'" title="Precio Unitario del Material/Servicio. Seleccione p
  
ara ver más detalles">'     
           SET @ETIQUETA_MENOR = ''    
          END    
            
             
    
    
         ---#END VALIDAR SI MATERIAL ES IGUAL AL MEJOR COSTO    
    
         ---#VALIDAR SI LA POD ESTA VENCIDA    
    
         IF @OFERTA_VENCIDA  = 0    
          BEGIN     
          
           ---#VALIDAR SI MATERIAL YA ESTA AGREGADO A LA LISTA TEMPORAL DE PEDIDO    
        
           IF @ADDLISTAPEDIDO = 1    
            BEGIN    
          
             SET @TABLA = @TABLA +'<h4><span class="semi-bold">$'+ CAST(CONVERT(NVARCHAR(MAX), CAST(@PRECIO_UNITARIO_ACTUAL AS money), 1) AS NVARCHAR(MAX))+'</span></H4><span class="text-black small-text">'+@TIPO_MONEDA_TEXT+' ' +@ICON_ADDPEDIDOTEMP+' '+'
  
<span class="badge badge-success" title="Cantidad agregada a la orden de compra">'+CAST(@ADD_CANTIDADTEMP AS nvarchar(50))+'</span></span>'      
            
            END     
    
           ELSE    
            BEGIN     
             SET @TABLA = @TABLA +'<h4><span class="semi-bold">$'+ CAST(CONVERT(NVARCHAR(MAX), CAST(@PRECIO_UNITARIO_ACTUAL AS money), 1) AS NVARCHAR(MAX))+'</span></h4><span class="text-black small-text">'+@TIPO_MONEDA_TEXT+'</span>'      
            END     
     
    
           ---#END VALIDAR SI MATERIAL YA ESTA AGREGADO A LA LISTA TEMPORAL DE PEDIDO        
          END     
         ELSE    
          BEGIN     
              
           IF @ADDLISTAPEDIDO = 1    
            BEGIN    
             SET @TABLA = @TABLA +'<h4><span class="semi-bold">$'+ CAST(CONVERT(NVARCHAR(MAX), CAST(@PRECIO_UNITARIO_ACTUAL AS money), 1) AS NVARCHAR(MAX))+'</span></h4>'+'<span class=" text-black small-text">'+@TIPO_MONEDA_TEXT+' ' +@ICON_ADDPEDIDOTEMP+'
  
 '+'<span class="badge badge-success" title="Cantidad agregada">'+CAST(@ADD_CANTIDADTEMP AS nvarchar(50))+'</span>&nbsp;'+@ICON_VENCIDO +'</span>'      
             END     
    
           ELSE    
            BEGIN     
             SET @TABLA = @TABLA +'<h4><span class="semi-bold">$'+ CAST(CAST(@PRECIO_UNITARIO_ACTUAL AS MONEY) AS NVARCHAR(MAX))+' </span></h4><span class="text-black small-text">'+@TIPO_MONEDA_TEXT+' '+@ICON_VENCIDO+'</span>'      
            END     
           
          --- SET @TABLA = @TABLA +'<h4><span class="semi-bold">$'+ CAST(CAST(@PRECIO_UNITARIO_ACTUAL AS MONEY) AS NVARCHAR(MAX))+' '+@ICON_VENCIDO+'</h4></span>'    
    
          END     
          
            
         -----FIN VALIDACIONES DE MATERIALES/SERVICIOS COTIZADOS    
        
       END     
      ELSE     
    
      ----ESTE MATERIAL ESTA DENTRO DE UNA PETICION COTIZADA PERO EL MATERIAL NO ESTA COTIZADO     
    
      BEGIN     
    
       SET @TABLA = @TABLA + '<td class="item_peticion" data-idPOD="'+CAST(ISNULL(@ID_POD,0) AS nvarchar(MAX))+'" data-Proveedor="'+CAST(@IdProveedorActual AS nvarchar(50))+'"    
                            title="El proveedor no cotizo este material">    
            <div  style="text-align:center">    
            <span class="label label-inverse"> NO COTIZADO </span>    
             </div>'           
          
    
      END     
    
    
    
       SET @TABLA = @TABLA + '</div>'    
        
      END     
     ---#END VALIDAR SI LA OFERTA ESTA COTIZADA ENTONCES MOSTRAR PRECIOS UNITARIOS ---    
     ELSE     
        
     BEGIN     
     ---#LA POD NO ESTA COTIZADA    
         
      --SET @TABLA = @TABLA + '<td class="item_peticion" data-idPOD="'+CAST(ISNULL(@ID_POD,0) AS nvarchar(MAX))+'" data-Proveedor="'+CAST(@IdProveedorActual AS nvarchar(50))+'">    
      --      <div  style="text-align:center">    
      --      <span class="label label-important">  NO COTIZADO </span>    
      --       </div>'    
           
      --SET @TABLA = @TABLA + '</div>'    
          
       IF @IsOfertaNoCotizada =1     
       BEGIN    
        SET @TABLA = @TABLA + '<td class="" data-idPOD="'+CAST(ISNULL(@ID_POD,0) AS nvarchar(MAX))+'" data-Proveedor="'+CAST(@IdProveedorActual AS nvarchar(50))+'">    
             <div  style="text-align:center">    
             <span class="label label-inverse"> NO COTIZADO </span>    
              </div>'    
       END     
       ELSE     
       BEGIN    
        SET @TABLA = @TABLA + '<td class="" data-idPOD="'+CAST(ISNULL(@ID_POD,0) AS nvarchar(MAX))+'" data-Proveedor="'+CAST(@IdProveedorActual AS nvarchar(50))+'">    
             <div  style="text-align:center">    
             <span class="label label-important"> NO COTIZADO </span>    
              </div>'    
       END     
           
        SET @TABLA = @TABLA + '</div>'    
    
    
     ---#END LA POD NO ESTA COTIZADA    
     END      
    
     END     
    ELSE    
     BEGIN     
      ---#OCULTAR PRECIOS     
    
      IF @IsOfertaCotizada = 1      
       BEGIN    
        SET @TABLA = @TABLA + '<td class="" data-idPOD="'+CAST(ISNULL(@ID_POD,0) AS nvarchar(MAX))+'" data-Proveedor="'+CAST(@IdProveedorActual AS nvarchar(50))+'">    
             <div  style="text-align:center">    
             <span class="label label-success"> COTIZADO </span>    
              </div>'    
           
        SET @TABLA = @TABLA + '</div>'    
       END     
      ELSE    
       BEGIN     
    
       --IF @IsOfertaNoCotizada =1     
    
       --BEGIN    
       -- SET @TABLA = @TABLA + '<td class="" data-idPOD="'+CAST(ISNULL(@ID_POD,0) AS nvarchar(MAX))+'" data-Proveedor="'+CAST(@IdProveedorActual AS nvarchar(50))+'">    
       --      <div  style="text-align:center">    
       --      <span class="label label-inverse"> NO COTIZADO </span>    
       --       </div>'    
       --END     
       --ELSE     
       --BEGIN    
        SET @TABLA = @TABLA + '<td class="" data-idPOD="'+CAST(ISNULL(@ID_POD,0) AS nvarchar(MAX))+'" data-Proveedor="'+CAST(@IdProveedorActual AS nvarchar(50))+'">    
             <div  style="text-align:center">    
             <span class="label label-important"> NO COTIZADO </span>    
              </div>'    
       --END     
           
        SET @TABLA = @TABLA + '</div>'    
       END     
     END     
    SET @TABLA = @TABLA + '</td>'    
    SET @COLUMN_PROVEEDOR = @COLUMN_PROVEEDOR + 1    
   END    
      
    
   SET @TABLA = @TABLA+'</tr>'     
   SET @ROW_MATERIAL = @ROW_MATERIAL + 1    
  END     
    
  ---# VALIDACIONES PARA MATRIZ EVALUACIÓN -----    
    
  DECLARE @COUNT_MATRIZ INT     
  DECLARE @IdProveedorActualM INT     
  DECLARE @IdEvaluacion NVARCHAR(MAX)     
  DECLARE @IdPeticionOfertaM INT     
  DECLARE @CALIFICACION_EVALUACION FLOAT     
    
  SET @COUNT_MATRIZ = (SELECT NombreDoc FROM TA_DocMatrizOperacion WHERE IdOperacion= @IdSolicitudPedido)    
    
  SET @IdEvaluacion = (SELECT NombreDoc FROM TA_DocMatrizOperacion WHERE IdOperacion= @IdSolicitudPedido )    
    
  IF @IdEvaluacion > 0     
  BEGIN     
   SET @TABLA = @TABLA+'<tr bgcolor="#ecf0f2">'    
    
    SET @TABLA = @TABLA+'<td colspan="2"><b>Resultado de Matriz de Evaluación.</b></td>'    
    ---SET @TABLA = @TABLA+'<td></td>'    
        
        
    SET @COLUMN_PROVEEDOR  = 1     
    
    WHILE @COLUMN_PROVEEDOR <=(SELECT COUNT(IdProveedor) FROM #PROVEEDORES)     
    BEGIN    
        SET @IdProveedorActualM   = (SELECT IdProveedor     
              FROM #PROVEEDORES     
              WHERE IdRow =@COLUMN_PROVEEDOR)    
    
      SET @IdPeticionOfertaM   = (SELECT IdPeticionOferta     
             FROM #PROVEEDORES     
             WHERE IdRow = @COLUMN_PROVEEDOR)    
    
    
      SET @IsOfertaCotizada = (SELECT ISNULL(Cotizado,0) AS PeticionCotizada          
            FROM MM_PeticionOferta AS PO    
            INNER JOIN #PROVEEDORES AS P ON P.IdProveedor = PO.IdSubcontratista    
            INNER JOIN MM_SolicitudPedido AS SP ON  SP.IdSolicitudPedido = PO.IdSolicitudPedido    
            WHERE PO.IdSolicitudPedido = @IdSolicitudPedido AND PO.IdPeticionOferta= @IdPeticionOfertaM AND IdRow =@COLUMN_PROVEEDOR)                          
              
    
      SET @IsOfertaNoCotizada = (SELECT NoCotizar AS PeticionNoCotizada          
             FROM MM_PeticionOferta AS PO    
             INNER JOIN #PROVEEDORES AS P ON P.IdProveedor = PO.IdSubcontratista    
             INNER JOIN MM_SolicitudPedido AS SP ON  SP.IdSolicitudPedido = PO.IdSolicitudPedido    
             WHERE PO.IdSolicitudPedido = @IdSolicitudPedido AND PO.IdPeticionOferta= @IdPeticionOfertaM AND IdRow =@COLUMN_PROVEEDOR)    
    
    
     IF @MOSTRAR_PRECIOS = 'SI'    
      BEGIN    
           
       IF @IsOfertaCotizada = 1     
        BEGIN     
    
        SET @CALIFICACION_EVALUACION = (SELECT ISNULL([Resultado], 0)    
                FROM [dbo].[ME_ResultadoMatriz] AS RM     
                WHERE RM.IdPedido =@IdPeticionOfertaM AND RM.IdProveedorEvaluado= @IdProveedorActualM)    
    
        SET @TABLA = @TABLA + '<td class="item_matriz" data-Evaluacion="'+CAST(ISNULL(@IdEvaluacion,0) AS nvarchar(MAX))+'" data-IdPO="'+CAST(ISNULL(@IdPeticionOfertaM,0) AS nvarchar(MAX))+'" data-Proveedor="'+CAST(@IdProveedorActualM AS nvarchar(50))+'">
  
    
                <div  style="text-align:center">'    
    
        SET @TABLA = @TABLA +'<span class="help">Puntuación</span> <br><h4><span class="semi-bold"> '+ CAST(ISNULL(@CALIFICACION_EVALUACION,0) AS NVARCHAR(MAX))+' </h4></span>'     
        SET @TABLA = @TABLA +'<span class="label label-success">VER RESPUESTAS </span></div>'    
        END     
       ELSE     
       BEGIN     
        SET @TABLA = @TABLA + '<td class="item_matriz_NO">    
               <div  style="text-align:center">    
               <span class="label label-important">EVALUACIÓN NO CONTESTADA </span>    
                </div>'    
    
       END     
      END     
     ELSE     
      BEGIN     
           
       IF @IsOfertaCotizada = 1    
    
        BEGIN     
         SET @TABLA = @TABLA + '<td class="item_matriz_NO">    
                <div  style="text-align:center">    
                <span class="label label-success">EVALUACIÓN FINALIZADA</span>    
                 </div>'    
        END     
       ELSE     
        BEGIN     
         SET @TABLA = @TABLA + '<td class="item_matriz_NO">    
                <div  style="text-align:center">    
                <span class="label label-important">EVALUACIÓN EN CURSO</span>    
                 </div>'    
    
        END     
      END     
         
    
     SET @COLUMN_PROVEEDOR  =  @COLUMN_PROVEEDOR  + 1     
    END     
    
    
    
    
    
   SET @TABLA = @TABLA+'</tr>'    
  END     
      
     
   SET @TABLA = @TABLA+'</tbody>'    
   SET @TABLA = @TABLA+'</table>'    
   ----------------- FIN CONDICION 2 ----------------------------------    
  END -- IF 1    
      
     
 SELECT @TABLA     
     
END    
    
    
    
    
    
    
    
    