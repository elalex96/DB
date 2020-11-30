
CREATE PROCEDURE dbo.sp_BI_LlenaTabla_BI_Oferta
AS
BEGIN
    SET NOCOUNT ON;

    --EN ESTATUS DE LA OFERTA SOLO LO PODEMOS PONER POR PARTIDA NO HAY UNA VIGENCIA POR CABECERA/ CADA MATERIAL  DE LA COTIZACIÓN TIENE SU PROPIA VIGENCIA 
    --FECHA DE VIGENCIA DE LA OFERTA IGUAL ES POR PARTIDA / CADA MATERIAL  DE LA COTIZACIÓN TIENE SU PROPIA VIGENCIA     
    
    DECLARE @Proveedores TABLE
    (
        IdProveedor INT
    );
    INSERT INTO @Proveedores
    (
        IdProveedor
    )
    VALUES
    (606),
    (676),
    (690),
    (1315),
    (1424),
    (1835);--> EMPRESA NUEVA

	DECLARE @OfertaVigencia AS TABLE(
	IdUnicoOferta INT,		
	Estatus VARCHAR(500)    
	)

	DECLARE @OfertaPedido AS TABLE(
	IdUnicoOferta INT,		
	Estatus VARCHAR(500)    
	)

	DECLARE @OfertaAsignados AS TABLE(
	IdSolicitudPedido INT,		
	Asignados VARCHAR(MAX)    
	)
	
    DECLARE @EstatusOferta TABLE
    (
        IdRequisicion INT,
        EstatusOferta VARCHAR(1000),        
		NumeroContrato VARCHAR(5000),
		Solicitante VARCHAR(5000),
		MotivoRequisicion VARCHAR(5000),
		Tipo VARCHAR(1000),
		EstatusGralOferta VARCHAR(500)
    );

	--OBTENER INFORMACIÓN DEL ESTATUS DE LOS PROVEEDORES QUE COTIZARON VS PROVEEDORES QUE SE INVITARON  COTIZAR Y DETALLE DE REQUISICIÓN
    INSERT INTO @EstatusOferta
    (
        IdRequisicion,
        EstatusOferta,        
		NumeroContrato,
		Solicitante,
		MotivoRequisicion,
		Tipo
		 
    )
    SELECT SP.IdSolicitudPedido,          
           CAST(SUM(   CASE
                           WHEN PO.NoCotizar = 1 THEN
                               1
                           ELSE
                               CASE
                                   WHEN PO.Cotizado = 1 THEN
                                       1
                                   ELSE
                                       0
                               END
                       END
                   ) AS NVARCHAR(MAX)) + '/' + CAST(COUNT(PO.IdPeticionOferta) AS NVARCHAR(MAX)) AS Nombre,           
		    C.NumeroContrato,
			US.Nombre,
			SP.MotivoUrgencia,
			CASE WHEN SP.IdTipoProceso=2 THEN 
				'Mercadeo'
			WHEN SP.IdTipoProceso=4 THEN  
				'Adjudicación directa'
			ELSE 
				''
			END			  
    FROM @Proveedores AS PV
        JOIN MM_SolicitudPedido AS SP (NOLOCK)
            ON PV.IdProveedor = SP.IdProveedor
		JOIN dbo.S_Usuario AS US (NOLOCK)
			ON SP.IdUsuarioSolicitante=US.IdUsuario
        JOIN TA_Operacion AS O (NOLOCK)
            ON SP.IdSolicitudPedido = O.IdDocumento
               AND O.IdTipoOperacion = 6 --> EN COTIZACIÓN
		JOIN Adinco.dbo.CO_Contrato AS C (NOLOCK)
			ON SP.IdContrato = C.IdContrato
        LEFT JOIN MM_PeticionOferta AS PO (NOLOCK)
            ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
    WHERE O.FechaFinalizacion IS NOT NULL
          AND ISNULL(O.IdEstatusEliminado, 0) <> 1 --> DIFERENTE DE ESTATUS ELIMINADO       
    GROUP BY 
	SP.IdSolicitudPedido, 
	C.NumeroContrato,
	US.Nombre,
	SP.MotivoUrgencia,
	SP.IdTipoProceso
    ORDER BY SP.IdSolicitudPedido DESC;
	
	--OBTENER LOS ASIGADOS A DE LA PETICIÓN DE OFERTA

	INSERT INTO @OfertaAsignados
	(
	    IdSolicitudPedido,
	    Asignados
	)

	SELECT SP.IdRequisicion,
	(
    STUFF(
            (
                SELECT CAST(', ' AS VARCHAR(MAX)) + CONVERT(NVARCHAR(MAX), ISNULL(U.Nombre, ''))
                FROM dbo.MM_SolicitudPedidoComprador AS SPC (NOLOCK)
                    INNER JOIN dbo.S_Usuario AS U (NOLOCK)
                        ON U.IdUsuario = SPC.IdAsignadoA
                WHERE SPC.IdSolicitudPedido =  SP.IdRequisicion                              
                ORDER BY U.Nombre ASC
                FOR XML PATH('')
            ),
            1,
            1,
            ''
                ))
		FROM @EstatusOferta SP
		     
	
	--ACTUALIZAR ESTATUS GRAL DE LA OFERTA HACIENDO REFERENCIA AA BI_REQUISIONES 
	UPDATE O
	SET O.EstatusGralOferta=R.EstatusCotizacion
	FROM @EstatusOferta O
	JOIN dbo.BI_Requisicion R 
	ON O.IdRequisicion=R.IdUnicoDeRequisicion

	--AGREGAR INFORMACIÓN A LA TABLA DE OFERTAS 
    TRUNCATE TABLE BI_Oferta;

    INSERT INTO BI_Oferta
    (
        IdSolicitudPedido,
        IdPeticionOferta,
        RazonSocial,
        EstatusCotizacion,
		FechaRegistro,
        FechaFinalizado,
        FechaFinOferta,
        EstatusOferta,
		TipoOferta,
		Descripcion,
		Asignados,
		Contrato,
		Solicitante,
		DescripcionGral,
		Tipo,
		EstatusGralOferta
    )
    SELECT DISTINCT
           R.IdSolicitudPedido AS 'No. Solicitud',
           PO.IdPeticionOferta AS 'idunico de oferta',
           S.RazonSocial AS 'Razon Social',
           CASE
               WHEN PO.Cotizado = 1 THEN
                   'COTIZADO'
			   WHEN PO.Cotizado = 0 THEN 
					'NO COTIZADO'
			   WHEN (DATEDIFF(MINUTE, O.FechaFinalizacion, GETDATE()) < 0) AND PO.Cotizado IS NULL THEN
					'EN COTIZACIÓN'
               ELSE
                   'NO COTIZADO/COTIZACIÓN VENCIDA'
           END AS 'Estatus Cotizacion',
           O.FechaRegistro AS 'Fecha Registro Oferta',
		   O.FechaFinalizacion AS 'Fecha Limite',
           CASE
               WHEN PO.Cotizado = 1 THEN
                   MAX(POD.FechaVigencia)
               ELSE
                   NULL
           END AS 'Fecha Fin de Oferta',
           EO.EstatusOferta AS 'Estatus',
           TSP.TipoSolicitudPedido AS 'Tipo Oferta',
           O.Descripcion AS 'Descripción',
           OA.Asignados AS 'Asignados',
		   EO.NumeroContrato AS 'Contrato',
		   EO.Solicitante AS 'Solicitante',
		   EO.MotivoRequisicion AS  'Descripcion pedido',
		   EO.Tipo AS 'Método de compra',  
		   EO.EstatusGralOferta AS 'Estatus cotizacion general'
    FROM @Proveedores PV
        JOIN MM_SolicitudPedido AS R (NOLOCK)
            ON PV.IdProveedor = R.IdProveedor		
        JOIN TA_Operacion AS O (NOLOCK)
            ON R.IdSolicitudPedido = O.IdDocumento
               AND O.IdTipoOperacion = 6 --> EN COTIZACIÓN
        JOIN MM_TipoSolicitudPedido AS TSP (NOLOCK)
            ON TSP.IdTipoSolicitudPedido = R.IdTipoSolicitudPedido
        JOIN MM_PeticionOferta AS PO (NOLOCK)
            ON R.IdSolicitudPedido = PO.IdSolicitudPedido
        JOIN S_Proveedor AS S (NOLOCK)
            ON S.IdProveedor = PO.IdSubcontratista
        JOIN MM_PeticionOfertaDetalle AS POD (NOLOCK)
            ON PO.IdPeticionOferta = POD.IdPeticionOferta           
        LEFT JOIN @EstatusOferta EO
            ON R.IdSolicitudPedido = EO.IdRequisicion
		LEFT JOIN @OfertaAsignados AS OA
		ON OA.IdSolicitudPedido= EO.IdRequisicion
    WHERE ISNULL(R.IdEstatusEliminado, 0) <> 1 --> DIFERENTE DE ESTATUS ELIMINADO     
    GROUP BY R.IdSolicitudPedido,
             PO.IdPeticionOferta,
             S.RazonSocial,
             PO.NoCotizar,
             PO.Cotizado,
             EO.EstatusOferta,
             PO.FechaFinalizado,
             TSP.TipoSolicitudPedido,
             O.Descripcion,
             OA.Asignados,
			 O.FechaFinalizacion,
			 EO.NumeroContrato,
			 EO.Solicitante,
			 EO.MotivoRequisicion,
			 O.FechaRegistro,
			 EO.Tipo,
			 EO.EstatusGralOferta
    ORDER BY R.IdSolicitudPedido ASC;

	--ACTUALIZAR ESTATUS DE COTIZACIÓN 	

	INSERT INTO @OfertaVigencia
	(
	    IdUnicoOferta,
	    Estatus
	)
	
	SELECT 
	OC.IdPeticionOferta,
	CASE WHEN (SUM(CASE 
			WHEN POD.FechaVigencia < GETDATE() THEN 1
			WHEN POD.FechaVigencia > GETDATE() THEN 0
			ELSE 0
		END)) > 1 THEN 'OFERTA DE PROVEEDOR VENCIDA'
		ELSE 
			'OFERTA DE PROVEEDOR VIGENTE'
		END 
	FROM dbo.BI_Oferta OC (NOLOCK)
	INNER JOIN dbo.MM_PeticionOfertaDetalle AS POD (NOLOCK)
	ON oc.IdPeticionOferta=POD.IdPeticionOferta 
	WHERE OC.EstatusCotizacion='COTIZADO'
	GROUP BY OC.IdPeticionOferta
	
	INSERT INTO @OfertaPedido
	(
	    IdUnicoOferta,
	    Estatus
	)
	
	SELECT 
	O.IdUnicoOferta,
	CASE WHEN SUM(P.IdPedido)> 0 THEN 
		'COTIZADO CON OC ADJUDICADA'
	ELSE 
		''	
	END
	FROM @OfertaVigencia AS O
	JOIN dbo.MM_Pedido AS P  (NOLOCK)
	ON P.IdPeticionOferta=O.IdUnicoOferta
	WHERE P.IdEstatusEliminado IS NULL
	GROUP BY O.IdUnicoOferta
	
	--PASO 1/2 ACTUALIZAR ESTATUS DE COTIZACIÓN CON OC ADJUDICADA

	UPDATE O 
	SET O.EstatusCotizacion=	OP.Estatus	
	FROM dbo.BI_Oferta O
	JOIN @OfertaPedido OP ON O.IdPeticionOferta=OP.IdUnicoOferta
	
	--PASO 2/2 CONCATENAR ESTATUS VIGENCIA 

	UPDATE O 
	SET O.EstatusCotizacion= CONCAT(O.EstatusCotizacion,' / ', OV.Estatus)	
	FROM dbo.BI_Oferta O
	JOIN @OfertaVigencia OV ON O.IdPeticionOferta=OV.IdUnicoOferta
		

END;
 

