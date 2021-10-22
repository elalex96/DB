if exists (select * from sys.procedures where name = 'SRAP_ConsultarSolicitudesAceptacionPedido')
begin
	drop proc SRAP_ConsultarSolicitudesAceptacionPedido
end

go
-- =============================================
-- Author:		Daniel AC
-- Create date: 25-05-2021
-- Description:	Consultar solicitudes de recepción de pedido
-- =============================================
CREATE PROCEDURE [dbo].[SRAP_ConsultarSolicitudesAceptacionPedido]  
	-- Add the parameters for the stored procedure here
@IdProveedor INT,
@IdUsuario   INT,
@IdContrato   INT,
@Filtro		 VARCHAR(200)
AS
 BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;
		 declare	@TipoOperacionId	int,
					@IdRol				int,
					@esAdministrador	bit	=	0,
					@esOBS				bit	=	0

		select	@TipoOperacionId	=	(SELECT IdTipoOperacion FROM TA_TipoOperacion WHERE NombreOperacion='Aprobación de solicitud de aceptación de pedido')
		select	@IdRol				=	IdRol from S_Rol where Rol = 'Administrador Solicitudes de Aceptación'
		
		/*Se verifica si tiene el Rol de "Administrador Solicitudes de Aceptación" */
		if exists(select * from S_UsuarioRol		where	IdUsuario = @IdUsuario and Activo = 1 and IdRol = @IdRol)
		begin
				select @esAdministrador	=	1
		end

		if exists(	select * from DEA_UsuarioOBS	where	IdUsuario = @IdUsuario and IdContrato =	@IdContrato and Activo=1)
		begin
				print 1
				select @esOBS			=	1
		end

		--select esAdministrador = @esAdministrador, esOBS = @esOBS
					    						
	    IF @Filtro ='TODAS'
		BEGIN 
		 
		SELECT		SAP.IdSolicitudAceptacionPedido,
					SAP.Comentario,
					P.IdPedido,    
					P.IdSolicitudPedido,    		 
					Proveedor								=	CONCAT(ISNULL(PC.RazonSocial,''),ISNULL(' '+PC.RegimenCapital,'')),    
					FechaEnvioPedido						=	FORMAT(ISNULL(P.FechaEnvioPedido, GETDATE()),'dd/MM/yyyy'),    
					P.IdPeticionOferta,    
					P.RecepcionServicio,    
					FechaRecepcionServicio					=	FORMAT(ISNULL(P.FechaRecepcionServicio,GETDATE()),'dd/MM/yyyy'),  
					IdPedidoGeneral							=	PG.IdPedido,
					Cerrado									=	ISNULL(P.Cerrado, 0),
					ProveedorVentaId						=	P.IdSubcontratista,
					EstatusAprobacion						=	E.Nombre,
					IdEstatus								=	O.IdEstatusOperacion,
					SolitudCreadaEl							=	FORMAT(ISNULL(SAP.CreadoEl, GETDATE()),'dd/MM/yyyy'),
					CreadoPor								=	UE.Nombre,
					Contrato								=	C.NumeroContrato,
					SolitanteRequisicion					=	US.Nombre,
					SAP.IdAceptacionPedido   
		FROM		MM_SolicitudAceptacionPedido			SAP
		JOIN		TA_Operacion							O 
		ON			SAP.IdSolicitudAceptacionPedido			=	O.IdDocumento
		AND			O.IdTipoOperacion						=	@TipoOperacionId -->CTE 20
		JOIN		TA_Estatus								E
		ON			O.IdEstatusOperacion					=	E.IdEstatus
		JOIN		MM_Pedido								P    
		ON			SAP.IdPedido							=	P.IdPedido
		INNER JOIN	MM_Pedidos								PG 
		ON			P.IdPedido								=	PG.IdIdentificador 
		AND			PG.IdProveedorCliente					=	P.IdProveedorCompras 
		AND			PG.IdTipoPedido							in	(2,4,6) 
		LEFT JOIN	S_Proveedor								PC 
		ON			P.IdSubcontratista						=	PC.IdProveedor
		LEFT JOIN	S_Usuario								UE
		ON			SAP.CreadorPor							=	UE.IdUsuario
		LEFT JOIN	Adinco..CO_Contrato						C
		ON			P.IdContrato							=	C.IdContrato
		LEFT JOIN	Adinco..CO_AreaContractual				AC
		ON			C.IdAreaContractual						=	AC.IdAreaContractual
		LEFT JOIN	MM_SolicitudPedido						SP
		ON			P.IdSolicitudPedido						=	SP.IdSolicitudPedido
		LEFT JOIN	S_Usuario								US
		ON			SP.Solicitante							=	US.IdUsuario
		left join	TA_Tarea								ta
		on			ta.IdOperacion							=	O.IdOperacion
		and			ta.IdAprobador							=	@IdUsuario
		WHERE		P.IdProveedorCompras					=	@IdProveedor 
		and			SAP.Activo								=	1
		and			((ta.IdAprobador						=	@IdUsuario) or @esOBS = 1 or @esAdministrador = 1)	
		and			C.IdContrato							=	@IdContrato
		GROUP BY    P.IdPedido,     
					 P.IdSolicitudPedido,		  
					 PC.RazonSocial,     
					 PC.RegimenCapital,
					 P.FechaEnvioPedido,    
					 P.IdPeticionOferta,    
					 P.RecepcionServicio,    
					 P.FechaRecepcionServicio,
					 PG.IdPedido,
					 P.DiasCredito,    
					 P.Cerrado,  
					 P.IdSubcontratista,
					 E.Nombre,
					 SAP.IdSolicitudAceptacionPedido,
					 SAP.Comentario,
					 O.IdEstatusOperacion,
					 SAP.CreadoEl,
					 UE.Nombre,
					 C.NumeroContrato,
					 US.Nombre,
					 SAP.IdAceptacionPedido 
		ORDER BY	SAP.IdSolicitudAceptacionPedido DESC	    	    
	END 

	IF @Filtro ='EN-APROBACION'
	 BEGIN 
		--select @esOBS
		SELECT		
		--			O.IdOperacion,
		--			ta.IdEstatus,
		--			ta.NoSecuencia,
					SAP.IdSolicitudAceptacionPedido,
					SAP.Comentario,
					P.IdPedido,    
					P.IdSolicitudPedido,    		 
					Proveedor						=	CONCAT(ISNULL(PC.RazonSocial,''),ISNULL(' '+PC.RegimenCapital,'')),    
					FechaEnvioPedido				=	FORMAT(ISNULL(P.FechaEnvioPedido, GETDATE()),'dd/MM/yyyy'),    
					P.IdPeticionOferta,    
					P.RecepcionServicio,    
					FechaRecepcionServicio			=	FORMAT(ISNULL(P.FechaRecepcionServicio,GETDATE()),'dd/MM/yyyy'),  
					IdPedidoGeneral					=	PG.IdPedido,
					Cerrado							=	ISNULL(P.Cerrado, 0),
					ProveedorVentaId				=	P.IdSubcontratista,
					EstatusAprobacion				=	E.Nombre,
					IdEstatus						=	O.IdEstatusOperacion,
					SolitudCreadaEl					=	FORMAT(ISNULL(SAP.CreadoEl, GETDATE()),'dd/MM/yyyy'),
					CreadoPor						=	UE.Nombre,
					Contrato						=	C.NumeroContrato,
					SolitanteRequisicion			=	US.Nombre,
					SAP.IdAceptacionPedido
		FROM		MM_SolicitudAceptacionPedido	SAP
		JOIN		TA_Operacion					O 
		ON			SAP.IdSolicitudAceptacionPedido =	O.IdDocumento
		AND			O.IdTipoOperacion				=	@TipoOperacionId -->CTE 20
		AND			O.IdEstatusOperacion			=	1 --> EN APROBACION CTE TA_Estatus
		JOIN		TA_Estatus						E
		ON			O.IdEstatusOperacion			=	E.IdEstatus
		JOIN		MM_Pedido						P    
		ON			SAP.IdPedido					=	P.IdPedido
		INNER JOIN	MM_Pedidos						PG 
		ON			P.IdPedido						=	PG.IdIdentificador 
		AND			PG.IdProveedorCliente			=	P.IdProveedorCompras 
		AND			PG.IdTipoPedido					in	(2,4,6) 
		LEFT JOIN	S_Proveedor						PC 
		ON			P.IdSubcontratista				=	PC.IdProveedor
		LEFT JOIN	S_Usuario						UE
		ON			SAP.CreadorPor					=	UE.IdUsuario
		LEFT JOIN	Adinco..CO_Contrato				C
		ON			P.IdContrato					=	C.IdContrato
		LEFT JOIN	Adinco..CO_AreaContractual		AC
		ON			C.IdAreaContractual				=	AC.IdAreaContractual
		LEFT JOIN	MM_SolicitudPedido				SP
		ON			P.IdSolicitudPedido				=	SP.IdSolicitudPedido
		LEFT JOIN	S_Usuario						US
		ON			SP.Solicitante					=	US.IdUsuario
		left join	TA_Tarea						ta
		on			ta.IdOperacion					=	O.IdOperacion
		WHERE 		P.IdProveedorCompras			=	@IdProveedor
		and			C.IdContrato					=	@IdContrato
		and			((ta.IdAprobador				=	@IdUsuario and ta.IdEstatus = 1)	or ((@esOBS = 1 )  and ta.IdEstatus = 2) )
		GROUP BY    
					P.IdPedido,     
					P.IdSolicitudPedido,		  
					PC.RazonSocial,     
					PC.RegimenCapital,
					P.FechaEnvioPedido,    
					P.IdPeticionOferta,    
					P.RecepcionServicio,    
					P.FechaRecepcionServicio,
					PG.IdPedido,
					P.DiasCredito,    
					P.Cerrado,  
					P.IdSubcontratista,
					E.Nombre,
					SAP.IdSolicitudAceptacionPedido,
					SAP.Comentario,
					O.IdEstatusOperacion,
					SAP.CreadoEl,
					UE.Nombre,
					C.NumeroContrato,
					US.Nombre,
					SAP.IdAceptacionPedido
		ORDER BY	SAP.IdSolicitudAceptacionPedido DESC	    
		END 
END 

go