use Petrovendor

go

if exists(select * from sys.procedures where name = 'spListaComprobantesExtranjeros')
begin
	drop proc spListaComprobantesExtranjeros
end

go

CREATE PROCEDURE [dbo].[spListaComprobantesExtranjeros]
	-- Add the parameters for the stored procedure here
	@IdProveedor INT,
	@Estatus INT,
	/*---------------------Parametros contrato---------------------*/
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
	/*---------------------Parametros contrato---------------------*/
AS
     BEGIN

	 create table #tmp
	 (
		IdUsuario					int,
		IdContrato					int,
		IdProveedorCompras			int,
		RazonSocial					varchar(max),
		IdAceptacionPedido			int,
		IdPedido					int,
		CreadoEl					date,
		NombreUsuarioEntrega		varchar(max),
		Proveedor					varchar(max),
		IdPedidoGeneral				int,
		IdTipoPedido				int,
		IdPedimentoComprobante		int,
		TipoPedido					varchar(max),
		TipoDocumentoFacturacion	varchar(max),
		IdOperacion					int,
		IdEstadoFlujo				int,
		IdEstatus					int,
		IdSolicitudPedido			int,
		Contrato					varchar(max)
	 )

	 --Validacion de flujo Serial
	 DECLARE @FlujoSerial TABLE
    (
        IdOperacion INT,
        NoSecuencia INT,
		IdUsuario	int
    );
    
	DECLARE @OperacionNoAprobadas TABLE 
	(	IdOperacion int, 
		IdUsuario	int,
		IdEstatus	int
	)

    INSERT INTO @FlujoSerial
    (
        IdOperacion,
        NoSecuencia,
		IdUsuario
    )
    SELECT O.IdOperacion,
           t.NoSecuencia,
		   t.IdAprobador
    FROM dbo.TA_Operacion O
        LEFT JOIN dbo.FI_PedimentoComprobante pc ON pc.IdPedimentoComprobante = o.IdDocumento
        INNER JOIN dbo.TA_Tarea t
            ON t.IdOperacion = O.IdOperacion
    WHERE O.IdTipoOperacion = 16
          AND ISNULL(O.IdEstatusEliminado, 0) <> 1 -->APROBACIÓN NO ESTE ELIMINADO
          AND ((t.IdAprobador = @IdUsuario)	or	@IdUsuario	=	-1)
          AND t.NoSecuencia > 1;
		  
    INSERT INTO @OperacionNoAprobadas
    (
        IdOperacion,
		IdUsuario,
		IdEstatus
    )
    SELECT		O.IdOperacion,
				f.IdUsuario,
				O.IdEstatusOperacion
    FROM		dbo.TA_Operacion	O
	INNER JOIN	@FlujoSerial f
    ON			f.IdOperacion		=	O.IdOperacion
	INNER JOIN	dbo.TA_Tarea T
	ON			T.IdOperacion		=	O.IdOperacion
	AND			T.NoSecuencia		=	(f.NoSecuencia - 1)
    WHERE		O.IdTipoOperacion	=	16
	AND			T.IdEstatus			<>	2

	
	
	IF @Estatus IN (1,2,3)
	BEGIN
		insert into	#tmp
		SELECT		t1.IdUsuario,
					C.IdContrato,
					P.IdProveedorCompras,
					Prov.RazonSocial,
					AP.IdAceptacionPedido,
					AP.IdPedido,
					CreadoEl						=	cast(AP.Creado as date),
					AP.NombreUsuarioEntrega,
					Proveedor						=	CONCAT(ISNULL(PR.RazonSocial, ''), ' ', ISNULL(PR.RegimenCapital, '')),
					IdPedidoGeneral					=	PG.IdPedido,
					TP.IdTipoPedido,
					PC.IdPedimentoComprobante,
					TP.TipoPedido ,
					TipoDocumentoFacturacion		=	CASE	WHEN PC.CvTipoDocFacturacion = 2 THEN  'Pedimento de importación'
																WHEN pc.CvTipoDocFacturacion = 3 THEN	'Comprobante Extranjero'
																END,
					O.IdOperacion,-- <<-----------
					O.IdEstadoFlujo,
					t1.IdEstatus,
					P.IdSolicitudPedido,
					Contrato										=	c.NumeroContrato
		FROM		dbo.MM_AceptacionPedido							AP 
		INNER JOIN	dbo.MM_Pedido									P 
		ON			P.IdPedido										=	AP.IdPedido
		INNER JOIN	MM_Pedidos										PG
		ON			P.IdPedido										=	PG.IdIdentificador
		AND			PG.IdProveedorCliente							=	P.IdProveedorCompras
		INNER JOIN	dbo.MM_TipoPedido								TP
		ON			TP.IdTipoPedido									=	PG.IdTipoPedido
		INNER JOIN	dbo.S_Proveedor									PR 
		ON			PR.IdProveedor									=	P.IdSubcontratista 
		INNER JOIN	dbo.FI_AceptacionPedido_PedimentoComprobante	APC 
		ON			APC.IdAceptacionPedido							=	AP.IdAceptacionPedido
		INNER JOIN	dbo.FI_PedimentoComprobante						PC 
		ON			PC.IdPedimentoComprobante						=	APC.IdPedimentoComprobante
		INNER JOIN	dbo.TA_Operacion								O 
		ON			O.IdDocumento									=	PC.IdPedimentoComprobante 
		AND			O.IdTipoOperacion								=	16 -->APROBACIÓN DE COMPROBANTE EXTRANJERO
		INNER JOIN	dbo.TA_Estatus									E
		ON			E.IdEstatus										=	O.IdEstatusOperacion		
		inner JOIN	Adinco.dbo.CO_Contrato							C 	
		ON			P.IdContrato									=	C.IdContrato 
		left join	@OperacionNoAprobadas							t1
		on			O.IdOperacion									=	t1.IdOperacion
		inner join	S_Proveedor										prov
		on			prov.IdProveedor								=	p.IdProveedorCompras
		WHERE		ISNULL(AP.IdNacionalidadProveedor, 0) = 2 --> NACIONALIDAD EXTRANJERA		
		AND			((P.IdProveedorCompras		=	@IdProveedor	)	or	@IdProveedor	=	-1)
		AND			((O.IdEstatusOperacion		=	@Estatus		)	or	@Estatus		=	-1)	
		AND			ISNULL(PC.IdEstatusEliminado,0)<> 1 --> NO MOSTRAR SOLICITUDES DE COMPROBANTE CON ESTATUS DE ELIMINADO = 1
		and			t1.IdOperacion									is	null
		--AND			O.IdOperacion NOT IN ( SELECT IdOperacion FROM @OperacionNoAprobadas)

		/*
		select top 100 * from adinco..CO_Registro
		select top 100 * from adinco..fi_transfer
		select top 100 * from adinco..FI_PedimentoComprobante
		*/
		 GROUP BY	t1.IdUsuario,
					C.IdContrato,
					P.IdProveedorCompras,
					Prov.RazonSocial,
					AP.IdAceptacionPedido,
					AP.IdPedido,
					AP.Creado,
					AP.NombreUsuarioEntrega,
					PR.RazonSocial,
					PR.RegimenCapital,
					PG.IdPedido,
					TP.IdTipoPedido,
					PC.IdPedimentoComprobante,
					TP.TipoPedido,
					O.IdEstatusOperacion,
					E.Nombre,
					PC.CvTipoDocFacturacion,
					O.IdOperacion,
					O.IdEstadoFlujo,
					t1.IdEstatus,
					PC.IdEstatusEliminado,
					P.IdSolicitudPedido,
					c.IdContrato,
					c.NumeroContrato
        ORDER BY	AP.IdAceptacionPedido DESC;		 
		 
       END  

	   select		IdUsuario,
					IdContrato,
					IdProveedorCompras,
					RazonSocial,
					IdAceptacionPedido,
					IdPedido,
					CreadoEl,
					NombreUsuarioEntrega,
					Proveedor,
					IdPedidoGeneral,
					IdTipoPedido,
					IdPedimentoComprobante,
					TipoPedido,
					TipoDocumentoFacturacion,
					IdOperacion,-- <<-----------
					IdEstadoFlujo,
					IdEstatus,
					IdSolicitudPedido,
					Contrato
		from		#tmp
		order by	IdPedido

	   select		t1.IdPedido,
					m.IdMaterial, 
					DescripcionCorta, 
					PrecioUnitario, 
					Cantidad, 
					Subtotal
	   from			MM_PedidoDetalle	pd
	   inner join	MM_Material			m	--select * from sys.tables where name like '%Materia%'
	   on			pd.IdMaterial		=	m.IdMaterial
	   inner join	#tmp				t1
	   on			pd.IdPedido			=	t1.IdPedido
	   group by		t1.IdPedido,
					m.IdMaterial, 
					DescripcionCorta, 
					PrecioUnitario, 
					Cantidad, 
					Subtotal
		order by	t1.IdPedido

  END

  go