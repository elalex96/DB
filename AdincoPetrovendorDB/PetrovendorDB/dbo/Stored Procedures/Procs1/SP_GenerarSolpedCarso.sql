USE [Petrovendor]
GO
IF OBJECT_ID('Petrovendor..SP_GenerarSolpedCarso') IS NOT NULL
BEGIN
DROP PROCEDURE SP_GenerarSolpedCarso;
END
GO
/****** Object:  StoredProcedure [dbo].[SP_GenerarSolpedCarso]    Script Date: 15/09/2020 04:04:46 p. m. ******/
-- =============================================
-- Author:		Daniel AC
-- Create date: 11/09/2020
-- Description: Se agrego personalización de la clasificicación dinamica del tipo del nuevo material si es un material o un servicio
-- Secciones que contiene el Store  
-- * SECCION DE CREACION DE TABLAS  
-- * SECCION DE INSERCION DE LA TABLA TEMPORAL  
-- * SECCION DE USUARIOS  
-- * SECCION MATERIALES  
-- * SECCION DOMICILIOs  
-- * SECCION CENTRO DE COSTOS  
-- * BUSQUEDA DE LINEAS DE PRESUPUESTO  
-- * VALIDACION DE DATOS  
-- * GUARDADO ENCABEZADO DE LA SOLPED  
-- * GUARDADO DETALLE DE LA SOLPED  
-- * ACTUALIZACION DE LA TABLA AX_COMPARATIVA  
-- * Creacion de la Operacion y marcada como Aprobada  
-- * GUARDADO DEL HISTORIAL DE LA SOLPED  
-- * Seccion de Alta de nuevo material, pero de una solped ya creada anteriormente  
-- * ACTUALIZACION DE TODOS LOS REGISTROS  
-- *   
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: 28/11/2023
-- Description:	SE CORRIGE LA ORTOGRAFÍA 
-- =============================================
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 08/07/2025
-- Description:	se elimina el envio de correos para enviarlos por medio del sdk
-- =============================================
CREATE PROCEDURE [dbo].[SP_GenerarSolpedCarso]
AS
BEGIN --EMPIEZA STORE    

    BEGIN -- SECCION DE CREACION DE TABLAS  

        DECLARE @TablaRegistrosActualizar TABLE
        (
            IdSolicitudPedidoDetalle INT,
            IdDinamicsAx INT
        );

        DECLARE @TablaIdDinamicsAxExistentes TABLE
        (
            IdDinamicsAx INT
        );

        DECLARE @TablaComparativaConSolped TABLE
        (
            IdComparativa NVARCHAR(MAX)
        );

        DECLARE @TablaAgrupacionSolpedCrearNuevas TABLE
        (
            Id INT IDENTITY,
            IdComparativa NVARCHAR(MAX),
            IdSolicitudPedido INT,
            IdFlujo INT,
            IdProveedor INT,
            IdAsignador INT,
            IdOperacion INT
        );

        DECLARE @TablaAgrupacionSolpedExistenteAgregarMaterial TABLE
        (
            IdDinamicsAx INT,
            IdComparativa NVARCHAR(MAX),
            IdSolicitudPedido INT,
            IdSolicitudPedidoDetalle INT
        );

        DECLARE @TablaComparativa TABLE
        (
            IdDinamicsAx INT,
            LineaPresupuesto NVARCHAR(MAX),
            Item NVARCHAR(MAX),
            Cantidad FLOAT,
            Unidad NVARCHAR(MAX),
            LugarEntrega NVARCHAR(MAX),
            Instalacion NVARCHAR(MAX),
            FechaEntrega DATE,
            TipoAdjudicacion INT,
            JustificacionPedido NVARCHAR(MAX),
            CentroCosto NVARCHAR(MAX),
            Aprobadores NVARCHAR(MAX),
            MensajeAprobacion NVARCHAR(MAX),
            Moneda NVARCHAR(MAX),
            IdComparativa NVARCHAR(MAX),
            IdPosicion NVARCHAR(MAX),
            DataAreaId NVARCHAR(MAX),
            FechaRegistro DATETIME,
            IdProveedor INT,
            IdUsuario INT,
            EditadoPor INT,
            EditadoEl DATETIME,
            Activo BIT,
            IdContrato INT,
            IdSolicitudPedido INT NULL,
            IdSolicitudPedidoDetalle INT NULL,
            IdMaterialSplit NVARCHAR(MAX),
            DescripcionMaterialSplit NVARCHAR(MAX),
            IdDomicilioPetrov INT,
            IdPresupuestoPetrov INT,
            IdPeriodoPetrov INT,
            IdUnidadPetrov INT,
            IdCentroCostoPetrov INT,
            IdMaterialPetrov INT,
            IdInstalacionPetrov INT,
            IdLineaPresupuestoPetrov INT,
            IdAreaContractual INT,
            IdUsuarioPetrov INT,
            ExisteSolpedDetalle INT,
            EliminadoError BIT,
            CharIndexUsuario INT,
            IdUsuarioAprobador INT,
            NombreUsuarioPetrov NVARCHAR(2000),
            NombreUsuarioAprobador NVARCHAR(2000)
        );

        DECLARE @TablaSolicitudPedido TABLE
        (
            IdContrato INT,
            IdTipoSolicitudPedido INT,
            IdUsuarioSolicitante INT,
            AdjudicableParcialmente BIT,
            IdPrioridadSolicitudPedido INT,
            MotivoUrgencia NVARCHAR(MAX),
            VisitaRequerida BIT,
            JuntaAclaracionesRequerida BIT,
            Controlados BIT,
            Fianza BIT,
            UnaSolaEntregaRequerida BIT,
            Activo BIT,
            FechaEntregaRequerida DATETIME,
            IdProveedor INT,
            FechaAlta DATETIME,
            EntregasParciales BIT,
            PeticionEnviada BIT,
            IdCentroCosto INT,
            IdTipoGasto INT,
            IdDomicilioEntrega INT,
            UnicoDomicilioEntrega BIT,
            IdPresupuesto INT,
            IdPeriodo INT,
            IdDinamicsAx INT,
            IdComparativa NVARCHAR(MAX),
            IdSolicitudPedido INT
        );

        DECLARE @TablaMaterialesAgregar TABLE
        (
            Id INT IDENTITY,
            Unidad NVARCHAR(MAX),
            DescripcionCorta NVARCHAR(MAX),
            IdProveedor INT,
            IdUnidad INT,
            IdMaterial INT,
            IdClasificiacionUnidad INT
        );

        DECLARE @TablaUnidadesAInsertar TABLE
        (
            Id INT IDENTITY,
            Unidad NVARCHAR(MAX),
            IdProveedor INT
        );

        DECLARE @TablaDomicilioAInsertar TABLE
        (
            IdTipoDomicilio INT,
            IdProveedor INT,
            IdCreadoPor INT,
            IdDomicilioPetrov INT,
            IdDomicilioAx NVARCHAR(200)
        );

        DECLARE @TablaCentroCostoAInsertar TABLE
        (
            IdProveedor INT,
            IdCreadoPor INT,
            IdCentroCostoPetrov INT,
            IdCentroCostoAx NVARCHAR(200)
        );

        DECLARE @TablaFlujos TABLE
        (
            Id INT,
            IdFLujoTarea INT,
            Condicion INT,
            Mensaje NVARCHAR(MAX),
            IdTipoFlujo INT,
            NombreOperacion NVARCHAR(MAX),
            IdTipoOperacion INT,
            IdProveedor INT,
            IsAsignador INT,
            Descripcion NVARCHAR(MAX)
        );

        DECLARE @TablaUsuario TABLE
        (
            NombreUsuarios NVARCHAR(2000),
            TipoUsuario NVARCHAR(500),
            IdDinamicsAx INT
        );
		
        DECLARE @TablaUsuariosAInsertar TABLE
        (
            NombreUsuarios NVARCHAR(2000),
            IdDinamicsAx INT
        );

        -- Son los registros que ya existen en la solicitud de pedido y son los que se deben de actualizar para estar constantemente  
        -- actualizados ya que el web service puede actualizar en cualquier momento los registros    

        INSERT INTO @TablaIdDinamicsAxExistentes
        (
            IdDinamicsAx
        )
        SELECT IdDinamicsAx
        FROM dbo.MM_SolicitudPedido
        WHERE IdDinamicsAx IS NOT NULL;

    END; -- FIN SECCION DE CREACION DE TABLAS     
		

    BEGIN -- // INICIO SECCION DE INSERCION DE LA TABLA TEMPORAL    

        -- Insertar los registros que aun no existen, solo a ellos se les hara el split para revisar si existen en el catalogo y si no insertarlo    

        -- El primer replace es para quitar en caso de que contengan un punto ya que es el delimitador del parsename y despues es para cambiar el guion - por un punto    

        INSERT INTO @TablaComparativa
        (
            IdDinamicsAx,
            LineaPresupuesto,
            Item,
            Cantidad,
            Unidad,
            LugarEntrega,
            Instalacion,
            FechaEntrega,
            TipoAdjudicacion,
            JustificacionPedido,
            CentroCosto,
            Aprobadores,
            MensajeAprobacion,
            Moneda,
            IdComparativa,
            IdPosicion,
            DataAreaId,
            FechaRegistro,
            IdProveedor,
            IdUsuario,
            EditadoPor,
            EditadoEl,
            Activo,
            IdContrato,
            IdSolicitudPedido,
            IdSolicitudPedidoDetalle,
            IdMaterialSplit,
            DescripcionMaterialSplit,
            CharIndexUsuario
        )
        SELECT ax.IdDinamicsAx,
               ax.LineaPresupuesto,
               ax.Item,
               ax.Cantidad,
               ax.Unidad,
               ax.LugarEntrega,
               ax.Instalacion,
               ax.FechaEntrega,
               NULL,
               ax.JustificacionPedido,
               ax.CentroCosto,
               ax.Aprobadores,
               ax.MensajeAprobacion,
               ax.Moneda,
               ax.IdComparativa,
               ax.IdPosicion,
               ax.DataAreaId,
               ax.FechaRegistro,
               ax.IdProveedor,
               ax.IdUsuario,
               ax.EditadoPor,
               ax.EditadoEl,
               ax.Activo,
               ax.IdContrato,
               ax.IdSolicitudPedido,
               ax.IdSolicitudPedidoDetalle,
               SUBSTRING(ax.Item, 1, 9),
               SUBSTRING(ax.Item, 11, LEN(ax.Item)),
               CHARINDEX('/', ax.Aprobadores)
        FROM dbo.AX_Comparativa ax;


        --Primero se buscan las instalaciones que no estan dadas de alta    
        -- para devolver al cliente que no se encontraron esas instalaciones	
        UPDATE comp
        SET comp.EliminadoError = 1,
            comp.IdInstalacionPetrov = NULL
        FROM @TablaComparativa comp
            LEFT JOIN Adinco.dbo.CO_Instalacion AS i
                ON UPPER(comp.Instalacion) COLLATE DATABASE_DEFAULT = UPPER(i.NombreInstalacion) 
            LEFT JOIN Adinco.dbo.CO_ActividadCIEP ciep
                ON i.IdActividad = ciep.IdActividad
        WHERE ciep.IdActividad IS NULL;

		
        -- se actualiza el id de la instalacion
        UPDATE comp
        SET comp.IdInstalacionPetrov = i.IdInstalacion
        FROM @TablaComparativa comp
            LEFT JOIN Adinco.dbo.CO_Instalacion AS i
                ON UPPER(comp.Instalacion) COLLATE DATABASE_DEFAULT = UPPER(i.NombreInstalacion) 
            LEFT JOIN Adinco.dbo.CO_ActividadCIEP ciep
                ON i.IdActividad = ciep.IdActividad
        WHERE ciep.IdActividad IS NOT NULL;
		
        -- se actualiza el IdProveedor por el del catalogo    

        UPDATE comparativa
        SET comparativa.IdProveedor = empresa.IdProveedor
        FROM @TablaComparativa comparativa
            INNER JOIN dbo.AX_ComparativaEmpresa empresa
                ON comparativa.DataAreaId = empresa.DataAreaID 
				
        -- Se inserta cuales son los Ids de la comparativa para saber cuales son las solicitudes que se van a crear    
        -- primero se obtiene las comparativas que ya tienen una solped asociada    

        INSERT INTO @TablaComparativaConSolped
        (
            IdComparativa
        )
        SELECT comp.IdComparativa
        FROM dbo.AX_Comparativa comp
        WHERE comp.IdSolicitudPedido IS NOT NULL
        GROUP BY comp.IdComparativa;
		

        -- y por ultimo cuales son las solpeds nuevas que se crearan    

        INSERT INTO @TablaAgrupacionSolpedCrearNuevas
        (
            IdComparativa
        )
        SELECT comp.IdComparativa
        FROM dbo.AX_Comparativa comp
            LEFT JOIN @TablaComparativaConSolped solped
                ON comp.IdComparativa = solped.IdComparativa
        WHERE solped.IdComparativa IS NULL
        GROUP BY comp.IdComparativa;

    END; -- FIN SECCION DE INSERCION DE LA TABLA TEMPORAL    
	

    BEGIN -- // INICIO SECCION DE USUARIOS    
	
        DECLARE @TablaQuitaUsuarioRepetido TABLE
        (
            NombreUsuarios NVARCHAR(2000),
            TipoUsuario NVARCHAR(500),
            IdDinamicsAx INT
        );

        UPDATE comp
        SET comp.NombreUsuarioPetrov = SUBSTRING(UPPER(LTRIM(RTRIM(Aprobadores))), 0, CharIndexUsuario),
            comp.NombreUsuarioAprobador = SUBSTRING(
                                                       UPPER(LTRIM(RTRIM(Aprobadores))),
                                                       CharIndexUsuario + 1,
                                                       LEN(LTRIM(RTRIM(Aprobadores)))
                                                   )
        FROM @TablaComparativa comp;



        -- Todos los usuarios de la tabla comparativa    

        INSERT INTO @TablaUsuario
        (
            NombreUsuarios,
            TipoUsuario,
            IdDinamicsAx
        )
        SELECT SUBSTRING(UPPER(LTRIM(RTRIM(Aprobadores))), 0, CharIndexUsuario),
               'Creador',
               IdDinamicsAx
        FROM @TablaComparativa;
		
        INSERT INTO @TablaUsuario
        (
            NombreUsuarios,
            TipoUsuario,
            IdDinamicsAx
        )
        SELECT SUBSTRING(UPPER(LTRIM(RTRIM(Aprobadores))), CharIndexUsuario + 1, LEN(LTRIM(RTRIM(Aprobadores)))),
               'Aprobador',
               IdDinamicsAx
        FROM @TablaComparativa;
		
        INSERT INTO @TablaQuitaUsuarioRepetido
        (
            NombreUsuarios,
            TipoUsuario,
            IdDinamicsAx
        )
        SELECT NombreUsuarios,
               TipoUsuario,
               IdDinamicsAx
        FROM @TablaUsuario
        WHERE NombreUsuarios <> ''
        GROUP BY NombreUsuarios,
                 TipoUsuario,
                 IdDinamicsAx;
				 
        DELETE @TablaUsuario;
		
        INSERT INTO @TablaUsuario
        (
            NombreUsuarios,
            TipoUsuario,
            IdDinamicsAx
        )
        SELECT NombreUsuarios,
               TipoUsuario,
               IdDinamicsAx
        FROM @TablaQuitaUsuarioRepetido;
		
        -- se obtiene los usuarios que no han sido dados de alta    

        INSERT INTO @TablaUsuariosAInsertar
        (
            NombreUsuarios,
            IdDinamicsAx
        )
        SELECT t.NombreUsuarios,
               t.IdDinamicsAx
        FROM dbo.S_Usuario u
            RIGHT JOIN @TablaUsuario t
                ON UPPER(u.Nombre) = UPPER(t.NombreUsuarios)
        WHERE u.IdUsuario IS NULL;
		
        -- Se guardan los usuarios que no han sido dados de alta    

        INSERT INTO dbo.S_Usuario
        (
            Nombre,
            Correo,
            Contrasena,
            Activo,
            IdTipoUsuario,
            FechaRegistro
        )
        SELECT NombreUsuarios,
               CONCAT(LOWER(REPLACE(NombreUsuarios, ' ', '')), '@', LOWER(REPLACE(NombreUsuarios, ' ', '')), '.com'),
               CONCAT(UPPER(NombreUsuarios), YEAR(GETDATE())),
               0,
               5,
               GETDATE()
        FROM @TablaUsuariosAInsertar;
		
        -- aqui se asigna los idusuarios que se crearon para el aprobador y para el creador de la solped    

        UPDATE comp
        SET comp.IdUsuarioPetrov = u.IdUsuario
        FROM @TablaComparativa comp
            INNER JOIN @TablaUsuariosAInsertar t
                ON UPPER(comp.IdDinamicsAx) = UPPER(t.IdDinamicsAx)
            INNER JOIN @TablaUsuario tu
                ON t.IdDinamicsAx = tu.IdDinamicsAx
                   AND UPPER(t.NombreUsuarios) = UPPER(tu.NombreUsuarios)
            INNER JOIN dbo.S_Usuario u
                ON UPPER(t.NombreUsuarios) = UPPER(u.Nombre) 
        WHERE tu.TipoUsuario = 'Creador';
		
        UPDATE comp
        SET comp.IdUsuarioAprobador = u.IdUsuario
        FROM @TablaComparativa comp
            INNER JOIN @TablaUsuariosAInsertar t
                ON UPPER(comp.IdDinamicsAx) = UPPER(t.IdDinamicsAx) 
            INNER JOIN @TablaUsuario tu
                ON t.IdDinamicsAx = tu.IdDinamicsAx 
                   AND UPPER(t.NombreUsuarios) = UPPER(tu.NombreUsuarios)
            INNER JOIN dbo.S_Usuario u
                ON UPPER(t.NombreUsuarios) = UPPER(u.Nombre) 
        WHERE tu.TipoUsuario = 'Aprobador';
		
        -- En caso de que tenga la logica anterior y sea el creador el mismo sea el aprobador entonces    

        UPDATE comp
        SET comp.NombreUsuarioPetrov = NombreUsuarioAprobador
        FROM @TablaComparativa comp
        WHERE ISNULL(NombreUsuarioPetrov, '') = '';
		
        --por ultimo se actualiza toda la tabla para los que hagan falta    

        UPDATE comp
        SET comp.IdUsuarioPetrov = u.IdUsuario
        FROM @TablaComparativa comp
            INNER JOIN dbo.S_Usuario u
                ON UPPER(comp.NombreUsuarioPetrov) = UPPER(u.Nombre);

        UPDATE comp
        SET comp.IdUsuarioAprobador = u.IdUsuario
        FROM @TablaComparativa comp
            INNER JOIN dbo.S_Usuario u
                ON  UPPER(comp.NombreUsuarioAprobador) = UPPER(u.Nombre);		

    END;
	
    -- FIN SECCIÓN DE USUARIO    
	
    --1 La línea de  presupuesto va a existir un catálogo hay que buscarlo en ese catálogo   	
    --2 Los materiales revisar si existen si no hay que agregarlos a su catálogo    
    -- Obtener los materiales que no existen en el catálogo de materiales esto incluye la unidad    

    BEGIN -- // INICIO MATERIALES    

        INSERT INTO @TablaMaterialesAgregar
        (
            Unidad,
            DescripcionCorta,
            IdProveedor
        )
        SELECT comp.Unidad,
               comp.DescripcionMaterialSplit,
               comp.IdProveedor
        FROM @TablaComparativa comp
            LEFT JOIN dbo.AX_MATERIAL m
                ON comp.IdMaterialSplit = m.IdMaterialAx
        WHERE m.IdMaterialAx IS NULL
        GROUP BY comp.Unidad,
                 comp.DescripcionMaterialSplit,
                 comp.IdProveedor;

        --Revisar que las unidades existan sino agregarlas    

        INSERT INTO @TablaUnidadesAInsertar
        (
            Unidad,
            IdProveedor
        )
        SELECT material.Unidad,
               material.IdProveedor
        FROM @TablaMaterialesAgregar material
            LEFT JOIN dbo.PV_MM_MaterialUnidad unidad
                ON material.Unidad = unidad.Unidad
        WHERE unidad.IdUnidad IS NULL;
		
        -- Se insertan las unidades que no existen    

        INSERT INTO dbo.PV_MM_MaterialUnidad
        (
            Unidad,
            UMB,
            IsActivo,
            IsEliminado,
            CreadoPor,
            CreadoEn
        )
        SELECT Unidad,
               NULL,
               1,
               0,
               0,
               GETDATE()
        FROM @TablaUnidadesAInsertar;
			

        -- Ya insertadas las unidades faltantes se tiene que actualizar el campo de la unidades para saber el idUnidad que se le asigno    

        UPDATE mat
        SET mat.IdUnidad = unidad.IdUnidad
        FROM @TablaMaterialesAgregar mat
            INNER JOIN dbo.PV_MM_MaterialUnidad unidad
                ON mat.Unidad = unidad.Unidad;

		 ---UNA VEZ QUE SE AGREGARON LAS NUEVAS UNIDADES OBTENER LA CLASIFICACIÓN DE LA UNIDAD (SERVICIO -->2/MATERIAL-->1) TABLA 
	     --SI LA UNIDAD ES NUEVA NO ESTARA EN LA TABLA CLASIFICACIÓN, PERO EN EL INSERT SE AGREGARIA POR DEFAUL COMO MATERIAL 

	    UPDATE mat
        SET mat.IdClasificiacionUnidad = clasificacion.IdClasificacion
        FROM @TablaMaterialesAgregar mat
            JOIN dbo.AX_UnidadClasificacion clasificacion
                ON mat.IdUnidad = clasificacion.IdUnidad; 

        INSERT INTO dbo.MM_Material
        (
            IdProveedor,
            IdSubFamilia,
            IdUnidad,
            IdTipo,
            DescripcionCorta,
            DescripcionLarga,
            Modelo,
            NumeroParte,
            Presentacion,
            Consumible,
            Inventariable,
            TiempoEntregaEstimadoDias,
            Marca,
            IsPublico,
            FechaAlta,
            Activo,
            IsEliminado,
            CreadoPor,
            IdTipoCatalogoMaestro,
            IdTipoProveedor
        )
        SELECT IdProveedor,
               NULL,
               IdUnidad,
               0,
               DescripcionCorta,
               DescripcionCorta,
               '',
               '',
               '',
               0,
               0,
               0,
               '',
               0,
               GETDATE(),
               1,
               0,
               0,
               ISNULL(IdClasificiacionUnidad,1),-->POR SI ES NULL SE INSERTA COMO MATERIAL
               1
        FROM @TablaMaterialesAgregar;
		
        UPDATE t
        SET t.IdMaterial = m.IdMaterial
        FROM @TablaMaterialesAgregar t
            INNER JOIN dbo.MM_Material m
                ON UPPER(t.DescripcionCorta) = UPPER(m.DescripcionCorta)
                   AND t.IdProveedor = m.IdProveedor
        WHERE m.DescripcionCorta != '';
		
        -- se actualiza la tabla de relación    

        UPDATE comp
        SET comp.IdMaterialPetrov = t.IdMaterial
        FROM @TablaComparativa comp
            INNER JOIN @TablaMaterialesAgregar t
                ON comp.IdProveedor = t.IdProveedor
                   AND UPPER(comp.DescripcionMaterialSplit) = UPPER(t.DescripcionCorta)
        WHERE t.IdMaterial IS NOT NULL;
		
        --se agrega a la tabla comparativa la unidad que esta en petrovendor    

        UPDATE comp
        SET comp.IdUnidadPetrov = u.IdUnidad
        FROM dbo.PV_MM_MaterialUnidad u
            INNER JOIN @TablaComparativa comp
                ON u.Unidad = comp.Unidad;
				
        INSERT INTO dbo.AX_MATERIAL
        (
            IdMaterialAx,
            IdMaterialPetrov
        )
        SELECT comp.IdMaterialSplit,
               comp.IdMaterialPetrov
        FROM @TablaComparativa comp
            LEFT JOIN dbo.AX_MATERIAL m
                ON comp.IdMaterialPetrov = m.IdMaterialPetrov 
        WHERE m.IdMaterialAx IS NULL
              AND comp.IdMaterialPetrov IS NOT NULL
              AND comp.IdMaterialSplit IS NOT NULL
        GROUP BY comp.IdMaterialSplit,
                 comp.IdMaterialPetrov;
				 
        UPDATE comp
        SET comp.IdMaterialPetrov = m.IdMaterialPetrov
        FROM @TablaComparativa comp
            INNER JOIN dbo.AX_MATERIAL m
                ON CAST(comp.IdMaterialSplit AS INT) = m.IdMaterialAx;
				
    END; -- // FIN MATERIALES    
	
    BEGIN -- // INICIO DOMICILIO    

        -- SE guardan los domicilios que aun no estan dados de alta    

        INSERT INTO @TablaDomicilioAInsertar
        (
            IdTipoDomicilio,
            IdProveedor,
            IdDomicilioAx
        )
        SELECT 5,
               comp.IdProveedor,
               comp.LugarEntrega
        FROM @TablaComparativa comp
            LEFT JOIN dbo.AX_DOMICILIO dom
                ON UPPER(comp.LugarEntrega) = UPPER(dom.IdDomicilioAx)
        WHERE dom.IdDomicilioAx IS NULL
        GROUP BY comp.IdProveedor,
                 comp.LugarEntrega;

        INSERT INTO dbo.DG_Domicilio
        (
            IdTipoDomicilio,
            IdProveedor,
            IdCreadoPor,
            FechaAlta,
            Activo,
            Calle
        )
        SELECT IdTipoDomicilio,
               IdProveedor,
               IdCreadoPor,
               GETDATE(),
               1,
               IdDomicilioAx
        FROM @TablaDomicilioAInsertar;

        UPDATE dom
        SET dom.IdDomicilioPetrov = dgDom.IdDomicilio
        FROM @TablaDomicilioAInsertar dom
            INNER JOIN dbo.DG_Domicilio dgDom
                ON dom.IdProveedor = dgDom.IdProveedor
                   AND UPPER(dom.IdDomicilioAx) = UPPER(dgDom.Calle)
        WHERE dom.IdDomicilioAx <> '';

        INSERT INTO dbo.AX_DOMICILIO
        (
            IdDomicilioAx,
            IdDomicilioPetrov
        )
        SELECT dom.IdDomicilioAx,
               dom.IdDomicilioPetrov
        FROM @TablaDomicilioAInsertar dom;

        UPDATE comp
        SET comp.IdDomicilioPetrov = dom.IdDomicilioPetrov
        FROM @TablaComparativa comp
            INNER JOIN dbo.AX_DOMICILIO dom
                ON UPPER(comp.LugarEntrega) = UPPER(dom.IdDomicilioAx);

    END; -- // FIN DOMICILIO    

	

    BEGIN -- // INICIO CENTRO DE COSTOS    

        UPDATE comp
        SET comp.IdCentroCostoPetrov = costo.IdCentroCostoPetrov
        FROM @TablaComparativa comp
            INNER JOIN dbo.AX_ComparativaEmpresa emp
                ON UPPER(comp.DataAreaId) = UPPER(emp.DataAreaID) 
                   AND comp.IdProveedor = emp.IdProveedor 
            INNER JOIN dbo.CC_CentroCosto cost
                ON emp.IdProveedor = cost.IdProveedor 
            INNER JOIN dbo.AX_CENTROCOSTO costo
                ON comp.CentroCosto = costo.IdCentroCostoAx 
                   AND cost.IdCentroCosto = costo.IdCentroCostoPetrov
				   

        -- centros de costos que solo estan dados de alta en CENTRO_COSTO pero no en AX_CENTROCOSTO    

        INSERT INTO @TablaCentroCostoAInsertar
        (
            IdProveedor,
            IdCentroCostoAx
        )
        SELECT comp.IdProveedor,
               comp.CentroCosto
        FROM @TablaComparativa comp
            LEFT JOIN dbo.AX_CENTROCOSTO costo
                ON comp.IdCentroCostoPetrov = costo.IdCentroCostoPetrov
        WHERE costo.IdCentroCostoAx IS NULL
        GROUP BY comp.IdProveedor,
                 comp.CentroCosto;
				 

        INSERT INTO dbo.AX_CENTROCOSTO
        (
            IdCentroCostoAx,
            IdCentroCostoPetrov
        )
        SELECT costo.IdCentroCostoAx,
               centro.IdCentroCosto
        FROM @TablaCentroCostoAInsertar costo
            INNER JOIN dbo.CC_CentroCosto centro
                ON costo.IdProveedor = centro.IdProveedor
                   AND UPPER(costo.IdCentroCostoAx) = UPPER(centro.CentroCosto);
				   					 				  

        UPDATE costo
        SET costo.IdCentroCostoPetrov = centro.IdCentroCosto
        FROM @TablaCentroCostoAInsertar costo
            INNER JOIN dbo.CC_CentroCosto centro
                ON costo.IdProveedor = centro.IdProveedor
                   AND UPPER(costo.IdCentroCostoAx) = UPPER(centro.CentroCosto);

    END; -- // FIN CENTRO DE COSTOS    

	   	 
    BEGIN -- // INICIO BUSQUEDA DE LINEAS DE PRESUPUESTO    
	        		
        -- En esta seccion se descomenta si la funcion ya se termino para buscar las lineas de presupuesto    

        UPDATE tComp
        SET tComp.IdLineaPresupuestoPetrov = IdLineaPresupuesto,
            tComp.IdPeriodoPetrov = periodo.IdPeriodo,
            tComp.IdPresupuestoPetrov = presupuesto.IdPresupuesto
        FROM @TablaComparativa tComp
            INNER JOIN dbo.AX_Comparativa comp
                ON tComp.IdDinamicsAx = comp.IdDinamicsAx
            INNER JOIN Adinco.dbo.CO_LineaPresupuestoMes linea
                ON comp.IdLineaPresupuesto = linea.IdLineaPresupuestoMes
            INNER JOIN Adinco.dbo.CO_Presupuesto presupuesto
                ON linea.IdPresupuesto = presupuesto.IdPresupuesto 
            INNER JOIN Adinco.dbo.CO_ProgramaActividad actividad
                ON presupuesto.IdProgramaActividad = actividad.IdProgramaActividad
            INNER JOIN Adinco.dbo.CO_PeriodoContrato periodo
                ON actividad.IdPeriodoContrato = periodo.IdPeriodo;

    END; -- // FIN PRESUPUESTO    
		   

    BEGIN --SECCIÓN VALIDACION DE DATOS    
	   
        -- se eliminan los registros que ya fueron dados de alta    

        UPDATE tComp
        SET tComp.ExisteSolpedDetalle = 1
        FROM @TablaComparativa tComp
            INNER JOIN dbo.AX_Comparativa comp
                ON tComp.IdDinamicsAx = comp.IdDinamicsAx 
        WHERE comp.IdSolicitudPedidoDetalle IS NOT NULL;
		
        UPDATE comp
        SET comp.EliminadoError = 1
        FROM @TablaComparativa comp
        WHERE (
                  comp.IdDomicilioPetrov IS NULL
                  OR comp.IdPresupuestoPetrov IS NULL
                  OR comp.IdPeriodoPetrov IS NULL
                  OR comp.IdUnidadPetrov IS NULL
                  OR comp.IdCentroCostoPetrov IS NULL
                  OR comp.IdMaterialPetrov IS NULL
                  OR comp.IdInstalacionPetrov IS NULL
                  OR comp.IdLineaPresupuestoPetrov IS NULL
                  OR comp.IdUsuarioPetrov IS NULL
                  OR comp.IdUsuarioAprobador IS NULL
              );    

    END;
		   	 
    BEGIN -- // INICIO GUARDADO ENCABEZADO DE LA SOLPED    

        INSERT INTO @TablaSolicitudPedido
        (
            IdContrato,
            IdTipoSolicitudPedido,
            IdUsuarioSolicitante,
            AdjudicableParcialmente,
            IdPrioridadSolicitudPedido,
            MotivoUrgencia,
            VisitaRequerida,
            JuntaAclaracionesRequerida,
            Controlados,
            Fianza,
            UnaSolaEntregaRequerida,
            Activo,
            FechaEntregaRequerida,
            IdProveedor,
            FechaAlta,
            EntregasParciales,
            PeticionEnviada,
            IdCentroCosto,
            IdTipoGasto,
            IdDomicilioEntrega,
            UnicoDomicilioEntrega,
            IdPresupuesto,
            IdPeriodo,
            IdDinamicsAx,
            IdComparativa
        )
        SELECT temp.IdContrato,
               temp.IdTipoSolicitudPedido,
               temp.IdUsuarioPetrov,
               temp.AdjudicableParcialmente,
               temp.IdPrioridadSolicitudPedido,
               temp.JustificacionPedido,
               temp.VisitaRequerida,
               temp.JuntaAclaracionesRequerida,
               temp.Controlados,
               temp.Fianza,
               temp.UnaSolaEntregaRequerida,
               temp.Activo,
               temp.FechaEntrega,
               temp.IdProveedor,
               temp.FechaRegistro,
               temp.EntregasParciales,
               temp.PeticionEnviada,
               temp.IdCentroCosto,
               temp.IdTipoGasto,
               temp.IdDomicilioPetrov,
               temp.UnicoDomicilioEntrega,
               temp.IdPresupuestoPetrov,
               temp.IdPeriodoPetrov,
               temp.IdDinamicsAx,
               temp.IdComparativa
        FROM
        (
            SELECT ROW_NUMBER() OVER (PARTITION BY comp.IdComparativa ORDER BY comp.IdComparativa DESC) AS rn,
                   comp.IdComparativa,
                   IdContrato,
                   10002 AS IdTipoSolicitudPedido,
                   comp.IdUsuarioPetrov,
                   1 AS AdjudicableParcialmente,
                   10001 AS IdPrioridadSolicitudPedido,
                   JustificacionPedido,
                   0 AS VisitaRequerida,
                   0 AS JuntaAclaracionesRequerida,
                   0 AS Controlados,
                   0 AS Fianza,
                   1 AS UnaSolaEntregaRequerida,
                   1 AS Activo,
                   FechaEntrega,
                   comp.IdProveedor,
                   FechaRegistro,
                   0 AS EntregasParciales,
                   0 AS PeticionEnviada,
                   0 AS IdCentroCosto,
                   0 AS IdTipoGasto,
                   comp.IdDomicilioPetrov,
                   0 AS UnicoDomicilioEntrega,
                   comp.IdPresupuestoPetrov,
                   comp.IdPeriodoPetrov,
                   IdDinamicsAx,
                   comp.IdMaterialPetrov
            FROM @TablaComparativa comp
                INNER JOIN @TablaAgrupacionSolpedCrearNuevas agrup
                    ON comp.IdComparativa = agrup.IdComparativa
            WHERE ISNULL(comp.EliminadoError, 0) = 0 

        ) temp
        WHERE temp.rn = 1
              AND temp.IdMaterialPetrov IS NOT NULL;


        -- Se inserta el encabezado    

        INSERT INTO dbo.MM_SolicitudPedido
        (
            IdContrato,
            IdTipoSolicitudPedido,
            IdUsuarioSolicitante,
            AdjudicableParcialmente,
            IdPrioridadSolicitudPedido,
            MotivoUrgencia,
            VisitaRequerida,
            JuntaAclaracionesRequerida,
            Controlados,
            Fianza,
            UnaSolaEntregaRequerida,
            Activo,
            FechaEntregaRequerida,
            IdProveedor,
            FechaAlta,
            EntregasParciales,
            PeticionEnviada,
            IdCentroCosto,
            IdTipoGasto,
            IdDomicilioEntrega,
            UnicoDomicilioEntrega,
            IdPresupuesto,
            IdPeriodo,
            IdDinamicsAx,
            Visible,
            IdLineaPresupuesto
        )
        SELECT IdContrato,
               IdTipoSolicitudPedido,
               IdUsuarioSolicitante,
               AdjudicableParcialmente,
               IdPrioridadSolicitudPedido,
               MotivoUrgencia,
               VisitaRequerida,
               JuntaAclaracionesRequerida,
               Controlados,
               Fianza,
               UnaSolaEntregaRequerida,
               Activo,
               FechaEntregaRequerida,
               IdProveedor,
               FechaAlta,
               EntregasParciales,
               PeticionEnviada,
               IdCentroCosto,
               IdTipoGasto,
               IdDomicilioEntrega,
               UnicoDomicilioEntrega,
               IdPresupuesto,
               IdPeriodo,
               IdDinamicsAx,
               1,
               0
        FROM @TablaSolicitudPedido;

    END; -- // FIN GUARDADO ENCABEZADO DE LA SOLPED    
	   	 

    BEGIN -- // INICIO GUARDADO DETALLE DE LA SOLPED    

        -- Ya insertado el encabezado hay que actualizar el idsolicitudpedido para saber cuales se insertaron    

        -- se actualiza la tabla intermedia de las solicitudes    

        UPDATE tSolped
        SET tSolped.IdSolicitudPedido = solped.IdSolicitudPedido
        FROM @TablaSolicitudPedido tSolped
            INNER JOIN dbo.MM_SolicitudPedido solped
                ON tSolped.IdDinamicsAx = solped.IdDinamicsAx;

        -- despues se actualiza la tabla temporal donde estan los encabezados y el detalle    

        UPDATE comp
        SET comp.IdSolicitudPedido = solped.IdSolicitudPedido
        FROM @TablaComparativa comp
            INNER JOIN @TablaSolicitudPedido solped
                ON comp.IdComparativa = solped.IdComparativa
        WHERE comp.IdSolicitudPedido IS NULL
              AND
              (
                  ISNULL(comp.EliminadoError, 0) = 0
                  AND ISNULL(comp.ExisteSolpedDetalle, 0) = 0
              );
			  			   			   

        -- Se actualiza la tabla para saber cuales son los detalles que se van a crear    

        UPDATE solped
        SET solped.IdSolicitudPedido = comp.IdSolicitudPedido,
            solped.IdProveedor = comp.IdProveedor
        FROM @TablaAgrupacionSolpedCrearNuevas solped
            INNER JOIN @TablaComparativa comp
                ON solped.IdComparativa = comp.IdComparativa;

        -- Se inserta el detalle de la solped    

        INSERT INTO dbo.MM_SolicitudPedidoDetalle
        (
            IdSolicitudPedido,
            IdMaterial,
            Fecha,
            Cantidad,
            observaciones,
            CreadoPor,
            IdUnidad,
            IdCentroCosto,
            IdDomicilioEntrega,
            IdDinamicsAx
        )
        SELECT comp.IdSolicitudPedido,
               comp.IdMaterialPetrov,
               GETDATE(),
               comp.Cantidad,
               comp.JustificacionPedido,
               0,
               comp.IdUnidadPetrov,
               comp.IdCentroCostoPetrov,
               comp.IdDomicilioPetrov,
               comp.IdDinamicsAx
        FROM @TablaComparativa comp
            INNER JOIN @TablaAgrupacionSolpedCrearNuevas filtro -- solo se insertan las solped nuevas creadas    
                ON comp.IdSolicitudPedido = filtro.IdSolicitudPedido
        WHERE (
                  ISNULL(comp.EliminadoError, 0) = 0
                  AND ISNULL(comp.ExisteSolpedDetalle, 0) = 0
              );

        -- Se actualiza el campo de la solicitud pedido detalle para saber cuales son los detalles que se insertaron    

        UPDATE comp
        SET comp.IdSolicitudPedidoDetalle = spd.IdSolicitudPedidoDetalle, 
            comp.IdCentroCostoPetrov = costo.IdCentroCosto
        FROM @TablaComparativa comp
            LEFT JOIN dbo.MM_SolicitudPedidoDetalle spd -- para que se inserte en todas las comparativas la solped que le corresponde   
                ON comp.IdDinamicsAx = spd.IdDinamicsAx
            INNER JOIN dbo.CC_CentroCosto costo
                ON comp.IdCentroCostoPetrov = costo.IdCentroCosto;


        -- Inserción de las líneas, centro de costo e instalaciones    

        INSERT INTO dbo.MM_SolicitudPedidoDetalleLineaPresupuesto
        (
            IdSolicitudPedidoDetalle,
            IdCentroCosto,
            IdInstalacion,
            IdLineaPresupuesto
        )
        SELECT comp.IdSolicitudPedidoDetalle,
               comp.IdCentroCostoPetrov,
               comp.IdInstalacionPetrov,
               comp.IdLineaPresupuestoPetrov
        FROM @TablaComparativa comp
            INNER JOIN @TablaAgrupacionSolpedCrearNuevas filtro
                ON comp.IdSolicitudPedido = filtro.IdSolicitudPedido
        WHERE comp.IdCentroCostoPetrov IS NOT NULL
              AND comp.IdInstalacionPetrov IS NOT NULL
              AND comp.IdLineaPresupuestoPetrov IS NOT NULL
              AND
              (
                  ISNULL(comp.EliminadoError, 0) = 0
                  AND ISNULL(comp.ExisteSolpedDetalle, 0) = 0
              )
        GROUP BY comp.IdSolicitudPedidoDetalle,
                 comp.IdCentroCostoPetrov,
                 comp.IdInstalacionPetrov,
                 comp.IdLineaPresupuestoPetrov,
                 comp.IdProveedor,
                 filtro.IdProveedor;

    END; -- // FIN GUARDADO DETALLE DE LA SOLPED    
	   	  
    BEGIN --ACTUALIZACION DE LA TABLA AX_COMPARATIVA    

        UPDATE axComp
        SET axComp.IdSolicitudPedido = comp.IdSolicitudPedido,
            axComp.IdSolicitudPedidoDetalle = comp.IdSolicitudPedidoDetalle
        FROM @TablaComparativa comp
            INNER JOIN dbo.AX_Comparativa axComp
                ON comp.IdDinamicsAx = axComp.IdDinamicsAx;

    END;

    BEGIN -- // INICIO DE LA OPERACION Creacion de la Operacion y marcada como Aprobada    

        INSERT INTO @TablaFlujos
        (
            Id,
            IdFLujoTarea,
            Condicion,
            Mensaje,
            IdTipoFlujo,
            NombreOperacion,
            IdTipoOperacion,
            IdProveedor,
            IsAsignador,
            Descripcion
        )
        SELECT temp.rn,
               temp.IdFLujoTarea,
               temp.Condicion,
               temp.Mensaje,
               temp.IdTipoFlujo,
               temp.NombreOperacion,
               temp.IdTipoOperacion,
               temp.IdProveedor,
               temp.IdUsuarioAprobador,
               temp.Descripcion
        FROM
        (
            SELECT ROW_NUMBER() OVER (PARTITION BY FT.IdProveedor ORDER BY FT.IdProveedor) AS rn,
                   IdFlujoTarea,
                   Condicion,
                   Mensaje,
                   IdTipoFlujo,
                   NombreOperacion,
                   TO_.IdTipoOperacion,
                   FT.IdProveedor,
                   comp.IdUsuarioAprobador,
                   Descripcion
            FROM TA_FlujoTarea AS FT
                INNER JOIN TA_TipoOperacion AS TO_
                    ON FT.IdTipoOperacion = TO_.IdTipoOperacion
                INNER JOIN @TablaComparativa comp
                    ON FT.IdProveedor = comp.IdProveedor 
            WHERE ISNULL(comp.EliminadoError, 0) <> 1
        ) AS temp
        WHERE temp.rn = 1
              AND temp.IdTipoOperacion = 2; -- Requisición    


        UPDATE solped
        SET solped.IdFlujo = flujo.IdFLujoTarea,
            solped.IdProveedor = comp.IdProveedor,
            solped.IdAsignador = comp.IdUsuarioPetrov
        FROM @TablaAgrupacionSolpedCrearNuevas solped
            INNER JOIN @TablaComparativa comp
                ON solped.IdComparativa = comp.IdComparativa
            INNER JOIN @TablaFlujos flujo
                ON comp.IdProveedor = flujo.IdProveedor
        WHERE ISNULL(comp.EliminadoError, 0) <> 1;
			   		 	  

        INSERT INTO dbo.TA_Operacion
        (
            IdDocumento,
            IdTipoOperacion,
            IdFlujoTarea,
            IdEstatusOperacion,
            IdEstadoFlujo,
            IdProveedor,
            IdAsignador,
            FechaRegistro,
            Descripcion,
            IdVigencia,
            IdPrioridad
        )
        SELECT solped.IdSolicitudPedido,
               2,
               solped.IdFlujo,
               1,
               1,
               solped.IdProveedor,
               solped.IdAsignador,
               GETDATE(),
               '',
               2,
               2
        FROM @TablaAgrupacionSolpedCrearNuevas solped
            INNER JOIN @TablaComparativa comp
                ON solped.IdSolicitudPedido = comp.IdSolicitudPedido
        GROUP BY solped.IdSolicitudPedido,
                 solped.IdFlujo,
                 solped.IdProveedor,
                 solped.IdAsignador;

        UPDATE solped
        SET solped.IdOperacion = tao.IdOperacion
        FROM @TablaAgrupacionSolpedCrearNuevas solped
            INNER JOIN dbo.TA_Operacion tao
                ON solped.IdSolicitudPedido = tao.IdDocumento
                   AND tao.IdTipoOperacion = 2;

				   					 				  
        INSERT INTO dbo.TA_Tarea
        (
            NombreTarea,
            FechaRegistro,
            IdEstatus,
            Activo,
            Visto,
            IdAprobador,
            NoSecuencia,
            IdOperacion,
            FechaCambioEstatus
        )
        SELECT flujo.NombreOperacion,
               GETDATE(),
               1,
               1,
               1,
               comp.IdUsuarioAprobador,
               1,
               solped.IdOperacion,
               GETDATE()
        FROM @TablaFlujos flujo
            INNER JOIN @TablaAgrupacionSolpedCrearNuevas solped
                ON flujo.IdFLujoTarea = solped.IdFlujo
            INNER JOIN @TablaComparativa comp
                ON solped.IdSolicitudPedido = comp.IdSolicitudPedido
        WHERE ISNULL(comp.EliminadoError, 0) <> 1;

        --relación tarea operación    

        INSERT INTO dbo.TA_TareaOperacion
        (
            IdTarea,
            IdOperacion
        )
        SELECT t.IdTarea,
               solped.IdOperacion
        FROM @TablaAgrupacionSolpedCrearNuevas solped
            INNER JOIN dbo.TA_Tarea t
                ON solped.IdOperacion = t.IdOperacion;
							   				 			  
        -- Se aprueba la solicitud de pedido    

        UPDATE t
        SET t.IdEstatus = 2,
            t.FechaCambioEstatus = GETDATE(),
            t.Comentario = ''
        FROM dbo.TA_Tarea t
            INNER JOIN @TablaAgrupacionSolpedCrearNuevas solped
                ON t.IdOperacion = solped.IdOperacion;

        UPDATE tao
        SET tao.IdEstatusOperacion = 2,
            tao.IdEstadoFlujo = 3
        FROM dbo.TA_Operacion tao
            INNER JOIN @TablaAgrupacionSolpedCrearNuevas solped
                ON tao.IdOperacion = solped.IdOperacion
                   AND tao.IdProveedor = solped.IdProveedor;

        -- GUARDADO DEL HISTORIAL DE LA SOLPED    

        INSERT INTO dbo.TA_HistorialFlujoTarea
        (
            IdOperacion,
            Fecha,
            Descripcion,
            IdEstadoFlujo
        )
        SELECT IdOperacion,
               GETDATE(),
               CONCAT(
                         'El Usuario ',
                         ISNULL(u.Nombre, 'Usuario no registrado'),
                         ' ha registrado la Tarea de Tipo Requisición'
                     ),
               1
        FROM @TablaAgrupacionSolpedCrearNuevas solped
            INNER JOIN dbo.S_Usuario u
                ON solped.IdAsignador = u.IdUsuario;

        -- Ya que lo toma del historial entonces actualizó nuevamente el usuario para que aparezca como aprobador    

        UPDATE solped
        SET solped.IdAsignador = comp.IdUsuarioAprobador
        FROM @TablaAgrupacionSolpedCrearNuevas solped
            INNER JOIN @TablaComparativa comp
                ON solped.IdComparativa = comp.IdComparativa
            INNER JOIN @TablaFlujos flujo
                ON comp.IdProveedor = flujo.IdProveedor;


        INSERT INTO dbo.TA_HistorialFlujoTarea
        (
            IdOperacion,
            Fecha,
            Descripcion,
            IdEstadoFlujo
        )
        SELECT IdOperacion,
               GETDATE(),
               CONCAT('El Usuario ', ISNULL(u.Nombre, 'Usuario no registrado'), ' ha Aprobado la Tarea'),
               2
        FROM @TablaAgrupacionSolpedCrearNuevas solped
            INNER JOIN dbo.S_Usuario u
                ON solped.IdAsignador = u.IdUsuario;

        INSERT INTO dbo.TA_HistorialFlujoTarea
        (
            IdOperacion,
            Fecha,
            Descripcion,
            IdEstadoFlujo
        )
        SELECT IdOperacion,
               GETDATE(),
               'Se ha Finalizado la aprobación de la Tarea ',
               7
        FROM @TablaAgrupacionSolpedCrearNuevas solped;

    END; -- FIN DE LA OPERACIÓN    
	   	 

    BEGIN -- Sección de Alta de nuevo material, pero de una solped ya creada anteriormente    

        UPDATE comp2
        SET comp2.IdSolicitudPedido = comp.IdSolicitudPedido
        FROM dbo.AX_Comparativa comp
            INNER JOIN dbo.AX_Comparativa comp2
                ON comp.IdComparativa = comp2.IdComparativa
        WHERE comp.IdSolicitudPedido IS NOT NULL;

        -- Saber cuales son los materiales que se van agregar    

        INSERT INTO @TablaAgrupacionSolpedExistenteAgregarMaterial
        (
            IdDinamicsAx,
            IdComparativa,
            IdSolicitudPedidoDetalle
        )
        SELECT comp.IdDinamicsAx,
               comp.IdComparativa,
               comp.IdSolicitudPedidoDetalle
        FROM dbo.AX_Comparativa comp
            INNER JOIN @TablaComparativa filtro
                ON comp.IdDinamicsAx = filtro.IdDinamicsAx
        WHERE comp.IdSolicitudPedidoDetalle IS NULL
              AND
              (
                  ISNULL(filtro.EliminadoError, 0) = 0
                  AND ISNULL(filtro.ExisteSolpedDetalle, 0) = 0
              );
			  			   			   			  
        -- Se inserta el detalle de la solped del material a agregar    

        INSERT INTO dbo.MM_SolicitudPedidoDetalle
        (
            IdSolicitudPedido,
            IdMaterial,
            Fecha,
            Cantidad,
            observaciones,
            CreadoPor,
            IdUnidad,
            IdCentroCosto,
            IdDomicilioEntrega,
            IdDinamicsAx
        )
        SELECT comp.IdSolicitudPedido,
               filtro.IdMaterialPetrov,
               GETDATE(),
               filtro.Cantidad,
               filtro.JustificacionPedido,
               0,
               filtro.IdUnidadPetrov,
               filtro.IdCentroCostoPetrov,
               filtro.IdDomicilioPetrov,
               comp.IdDinamicsAx
        FROM dbo.AX_Comparativa comp
            INNER JOIN @TablaComparativa filtro
                ON comp.IdDinamicsAx = filtro.IdDinamicsAx
        WHERE comp.IdSolicitudPedidoDetalle IS NULL
              AND
              (
                  ISNULL(filtro.EliminadoError, 0) = 0
                  AND ISNULL(filtro.ExisteSolpedDetalle, 0) = 0
              );

			  			   			   
        -- Se actualiza el campo de la solicitud pedido detalle para saber cuales son los detalles que se insertaron    

        UPDATE comp
        SET comp.IdSolicitudPedidoDetalle = spd.IdSolicitudPedidoDetalle
        FROM dbo.AX_Comparativa comp
            INNER JOIN dbo.MM_SolicitudPedidoDetalle spd
                ON comp.IdDinamicsAx = spd.IdDinamicsAx;

        UPDATE det
        SET det.IdSolicitudPedidoDetalle = spd.IdSolicitudPedidoDetalle
        FROM @TablaAgrupacionSolpedExistenteAgregarMaterial det
            INNER JOIN dbo.MM_SolicitudPedidoDetalle spd
                ON det.IdDinamicsAx = spd.IdDinamicsAx;


        --Inserción de las líneas, centro de costo e instalaciones    

        INSERT INTO dbo.MM_SolicitudPedidoDetalleLineaPresupuesto
        (
            IdSolicitudPedidoDetalle,
            IdCentroCosto,
            IdInstalacion,
            IdLineaPresupuesto
        )
        SELECT m.IdSolicitudPedidoDetalle,
               comp.IdCentroCostoPetrov,
               comp.IdInstalacionPetrov,
               comp.IdLineaPresupuestoPetrov
        FROM @TablaComparativa comp
            INNER JOIN @TablaAgrupacionSolpedExistenteAgregarMaterial m
                ON comp.IdDinamicsAx = m.IdDinamicsAx
        WHERE comp.IdCentroCostoPetrov IS NOT NULL
              AND
              (
                  ISNULL(comp.EliminadoError, 0) = 0
                  AND ISNULL(comp.ExisteSolpedDetalle, 0) = 0
              );

    END;


    BEGIN -- ACTUALIZACION DE TODOS LOS REGISTROS    

        --Tabla donde se van a actualizar los registros    

        INSERT INTO @TablaRegistrosActualizar
        (
            IdSolicitudPedidoDetalle,
            IdDinamicsAx
        )
        SELECT IdSolicitudPedidoDetalle,
               IdDinamicsAx
        FROM dbo.AX_Comparativa
        WHERE Editado = 1;
			   		       
        --Se tiene que actualizar la tabla comparativa ya que es de donde se van a tomar todos los datos    

        UPDATE tComp
        SET tComp.IdMaterialPetrov = ISNULL(m.IdMaterialPetrov, tComp.Item),
            tComp.Cantidad = ISNULL(comp.Cantidad, tComp.Cantidad),
            tComp.IdUnidadPetrov = ISNULL(unidad.IdUnidad, tComp.Unidad),
            tComp.IdCentroCostoPetrov = ISNULL(costo.IdCentroCostoPetrov, tComp.CentroCosto),
            tComp.FechaEntrega = ISNULL(comp.FechaEntrega, tComp.FechaEntrega),
            tComp.IdDomicilioPetrov = ISNULL(dom.IdDomicilioPetrov, tComp.IdDomicilioPetrov),
            tComp.LugarEntrega = ISNULL(comp.LugarEntrega, tComp.LugarEntrega),
            tComp.Instalacion = ISNULL(comp.Instalacion, tComp.Instalacion),
            tComp.IdInstalacionPetrov = ISNULL(inst.IdInstalacion, tComp.IdInstalacionPetrov),
            tComp.Aprobadores = ISNULL(comp.Aprobadores, tComp.Aprobadores),
            tComp.JustificacionPedido = ISNULL(comp.JustificacionPedido, tComp.JustificacionPedido),
            tComp.IdContrato = ISNULL(comp.IdContrato, tComp.IdContrato)
        FROM @TablaComparativa tComp
            INNER JOIN dbo.AX_Comparativa comp
                ON tComp.IdDinamicsAx = comp.IdDinamicsAx
            INNER JOIN @TablaRegistrosActualizar act
                ON comp.IdDinamicsAx = act.IdDinamicsAx  --filtro    
            LEFT JOIN dbo.AX_CENTROCOSTO costo
                ON tComp.CentroCosto = costo.IdCentroCostoAx 
            LEFT JOIN dbo.AX_DOMICILIO dom
                ON tComp.LugarEntrega = dom.IdDomicilioAx
            LEFT JOIN dbo.AX_MATERIAL m
                ON tComp.IdMaterialSplit = m.IdMaterialAx 
            LEFT JOIN dbo.PV_MM_MaterialUnidad unidad
                ON comp.Unidad = unidad.Unidad
            LEFT JOIN Adinco.dbo.CO_Instalacion inst
                ON UPPER(inst.NombreInstalacion)  COLLATE DATABASE_DEFAULT = UPPER(comp.Instalacion)
        WHERE ISNULL(tComp.EliminadoError, 0) <> 1;


        UPDATE sp
        SET sp.IdContrato = comp.IdContrato,
            sp.FechaEntregaRequerida = comp.FechaEntrega,
            sp.MotivoUrgencia = comp.JustificacionPedido,
            sp.FechaAlta = comp.FechaRegistro,
            sp.IdUsuarioSolicitante = comp.IdUsuarioPetrov,
            sp.IdPeriodo = comp.IdPeriodoPetrov,
            sp.IdPresupuesto = comp.IdPresupuestoPetrov
        FROM @TablaComparativa comp
            INNER JOIN @TablaRegistrosActualizar act
                ON comp.IdDinamicsAx = act.IdDinamicsAx
            INNER JOIN dbo.MM_SolicitudPedido sp
                ON comp.IdDinamicsAx = sp.IdDinamicsAx
        WHERE ISNULL(comp.EliminadoError, 0) <> 1;


        UPDATE spd
        SET spd.IdMaterial = comp.IdMaterialPetrov,
            spd.Cantidad = comp.Cantidad,
            spd.IdUnidad = comp.IdUnidadPetrov,
            spd.observaciones = comp.JustificacionPedido,
            spd.IdDomicilioEntrega = comp.IdDomicilioPetrov
        FROM dbo.MM_SolicitudPedidoDetalle spd
            INNER JOIN @TablaComparativa comp
                ON spd.IdDinamicsAx = comp.IdDinamicsAx
            INNER JOIN @TablaRegistrosActualizar act
                ON comp.IdDinamicsAx = act.IdDinamicsAx
        WHERE ISNULL(comp.EliminadoError, 0) <> 1;

			   
        UPDATE spdl
        SET spdl.IdCentroCosto = comp.IdCentroCostoPetrov,
            spdl.IdInstalacion = comp.IdInstalacionPetrov,
            spdl.IdLineaPresupuesto = comp.IdLineaPresupuestoPetrov
        FROM dbo.MM_SolicitudPedidoDetalleLineaPresupuesto spdl
            INNER JOIN dbo.MM_SolicitudPedidoDetalle spd
                ON spdl.IdSolicitudPedidoDetalle = spd.IdSolicitudPedidoDetalle
            INNER JOIN @TablaComparativa comp
                ON spd.IdDinamicsAx = comp.IdDinamicsAx
            INNER JOIN @TablaRegistrosActualizar act
                ON comp.IdDinamicsAx = act.IdDinamicsAx
        WHERE ISNULL(comp.EliminadoError, 0) <> 1;

        -- Ya que se actualizó el dato, volver a setearlo a no editado    

        UPDATE comp
        SET comp.Editado = 0
        FROM @TablaRegistrosActualizar act
            INNER JOIN dbo.AX_Comparativa comp
                ON act.IdDinamicsAx = comp.IdDinamicsAx;

    END;
		   	  
    --Retorno de tabla incorrectos    

    INSERT INTO dbo.Ax_Incorrectos
    (
        IdTipoOperacion,
        IdDocumento,
        Enviado,
        FechaRegistro
    )
    SELECT 2,
           comp.IdDinamicsAx,
           0,
           GETDATE()
    FROM @TablaComparativa comp
        LEFT JOIN dbo.Ax_Incorrectos i
            ON comp.IdDinamicsAx = i.IdDocumento
               AND i.IdTipoOperacion = 2
               AND ISNULL(i.Enviado, 0) = 0
    WHERE i.IdTipoOperacion IS NULL
          AND
          (
              comp.IdSolicitudPedido IS NULL
              OR comp.IdSolicitudPedidoDetalle IS NULL
          );

		  		   		   
    -- Motivo por el cual no se creo    

    UPDATE i
    SET i.Motivo = CONCAT(   CASE
                                 WHEN comp.IdDomicilioPetrov IS NULL THEN
                                     ' Domicilio No Registrado -'
                                 ELSE
                                     ''
                             END,
                             CASE
                                 WHEN comp.IdPresupuestoPetrov IS NULL THEN
                                     ' Presupuesto No Registrado -'
                                 ELSE
                                     ''
                             END,
                             CASE
                                 WHEN comp.IdPeriodoPetrov IS NULL THEN
                                     ' Periodo No Registrado -'
                                 ELSE
                                     ''
                             END,
                             CASE
                                 WHEN comp.IdUnidadPetrov IS NULL THEN
                                     ' Unidad No Registrado -'
                                 ELSE
                                     ''
                             END,
                             CASE
                                 WHEN comp.IdCentroCostoPetrov IS NULL THEN
                                     ' Centro Costo No Registrado o DataArea No reconocida-'
                                 ELSE
                                     ''
                             END,
                             CASE
                                 WHEN comp.IdMaterialPetrov IS NULL THEN
                                     ' Material No Registrado -'
                                 ELSE
                                     ''
                             END,
                             CASE
                                 WHEN comp.IdInstalacionPetrov IS NULL THEN
                                     ' Instalación No Registrada '
                                 ELSE
                                     ''
                             END,
                             CASE
                                 WHEN comp.IdLineaPresupuestoPetrov IS NULL THEN
                                     ' Línea No Registrada -'
                                 ELSE
                                     ''
                             END,
                             CASE
                                 WHEN comp.IdUsuarioPetrov IS NULL THEN
                                     ' Usuario Creado Solped No Registrado '
                                 ELSE
                                     ''
                             END,
                             CASE
                                 WHEN comp.IdUsuarioAprobador IS NULL THEN
                                     ' Usuario Aprobador No Registrado '
                                 ELSE
                                     ''
                             END
                         )
    FROM @TablaComparativa comp
        INNER JOIN dbo.Ax_Incorrectos i
            ON comp.IdDinamicsAx = i.IdDocumento
               AND i.IdTipoOperacion = 2;
			   				 
    -- Retorno cuales no se crearon y por que    

    INSERT INTO dbo.Ax_ComparativaErrorLog
    (
        IdDinamicsAx,
        IdDocumento,
        Motivo,
        FechaRegistro
    )
    SELECT comp.IdDinamicsAx,
           i.IdDocumento,
           i.Motivo,
           i.FechaRegistro
    FROM dbo.Ax_Incorrectos i
        INNER JOIN @TablaComparativa comp
            ON i.IdDocumento = comp.IdDinamicsAx
               AND i.IdTipoOperacion = 2
               AND i.Enviado = 0
    WHERE (
              comp.IdSolicitudPedido IS NULL
              OR comp.IdSolicitudPedidoDetalle IS NULL
          ); -- filtrar en caso de que ya se haya creado    

    UPDATE comp
    SET comp.EnvioCorreo = 1
    FROM @TablaAgrupacionSolpedCrearNuevas solped
        INNER JOIN dbo.AX_Comparativa comp
            ON solped.IdComparativa = comp.IdComparativa
    WHERE solped.IdSolicitudPedido IS NOT NULL;

    --Retorno los que tuvieron error
    SELECT IdDinamicsAx,
           LineaPresupuesto,
           Item,
           Cantidad,
           Unidad,
           LugarEntrega,
           Instalacion,
           FechaEntrega,
           TipoAdjudicacion,
           JustificacionPedido,
           CentroCosto,
           Aprobadores,
           MensajeAprobacion,
           Moneda,
           IdComparativa,
           IdPosicion,
           DataAreaId,
           FechaRegistro,
           IdProveedor,
           IdUsuario,
           EditadoPor,
           EditadoEl,
           Activo,
           IdContrato,
           IdSolicitudPedido,
           IdSolicitudPedidoDetalle,
           IdMaterialSplit,
           DescripcionMaterialSplit,
           IdDomicilioPetrov,
           IdPresupuestoPetrov,
           IdPeriodoPetrov,
           IdUnidadPetrov,
           IdCentroCostoPetrov,
           IdMaterialPetrov,
           IdInstalacionPetrov,
           IdLineaPresupuestoPetrov,
           IdAreaContractual,
           IdUsuarioPetrov,
           ExisteSolpedDetalle,
           EliminadoError,
           CharIndexUsuario,
           IdUsuarioAprobador,
           NombreUsuarioPetrov,
           NombreUsuarioAprobador
    FROM @TablaComparativa
    WHERE EliminadoError = 1;

	

END; -- TERMINA STORE
