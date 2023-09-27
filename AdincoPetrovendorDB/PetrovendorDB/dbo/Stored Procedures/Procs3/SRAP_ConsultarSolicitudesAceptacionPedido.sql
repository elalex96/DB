use petrovendor
go
drop proc if exists SRAP_ConsultarSolicitudesAceptacionPedido
go
-- =============================================
-- Author:		Daniel AC
-- Create date: 25-05-2021
-- Description:	Consultar solicitudes de recepción de pedido
-- =============================================
-- 24/11/2021 MC quitar prints ISSUE 383 adincopetrodb
-- =============================================
-- Author:		LUIS DAVID
-- Create date: 02/03/2022
-- Description:	SE AGREGA EL PO PARA DEA ISSUE#1651
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: 27-04-2022
-- Description:	Issue #1739  Optimizacion pantallas se ordena y revisa joins 
-- =============================================
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 05/05/2022
-- Description:	Issue #1765  adecuaciones para mostrar las solicitudes pendientes a los usuarios obs
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: 08-06-2022
-- Description:	Se revierte Eliminado temporal de la primera aprobacion de aceptacion de pedido
-- =============================================
-- =============================================
-- Author:		Luis David
-- Create date: 06-10-2022
-- Description:	Issue #2056 elminación  adecuaciones para mostrar las solicitudes pendientes a los usuarios obs
-- =============================================
-- Author:		Luis David
-- Create date: 27/09/2023
-- Description:	Issue #2502 cambia el comentario a Max para no generar error de data trucated
-- =============================================
CREATE PROCEDURE [dbo].[SRAP_ConsultarSolicitudesAceptacionPedido]
	-- Add the parameters for the stored procedure here
@IdProveedor INT,
@IdUsuario   INT,
@IdContrato  INT,
@Filtro		 VARCHAR(200)
AS
 BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;
		 declare	@TipoOperacionId	int,
					@IdRol				int,
					@esAdministrador	bit	= 0,
					@esOBS				bit	= 0

		select	@TipoOperacionId	=	(SELECT IdTipoOperacion FROM TA_TipoOperacion WHERE NombreOperacion='Aprobación de solicitud de aceptación de pedido')
		select	@IdRol				=	IdRol from S_Rol where Rol = 'Administrador Solicitudes de Aceptación'
		
		/*Se verifica si tiene el Rol de "Administrador Solicitudes de Aceptación" */
		if exists(select 1 from S_UsuarioRol where IdUsuario = @IdUsuario and Activo = 1 and IdRol = @IdRol)
		begin
				select @esAdministrador	=	1
		end

		if exists(select 1 from DEA_UsuarioOBS where IdUsuario = @IdUsuario and IdContrato = @IdContrato and Activo=1)
		begin
				select @esOBS =	1
		end
		drop table if exists #AprobacionesOBSyRequisitor
		create table #AprobacionesOBSyRequisitor(
					IdSolicitudAceptacionPedido int,
					Comentario varchar(MAX),
					IdPedido int,    
					IdSolicitudPedido int,    		 
					Proveedor varchar(1000),    
					FechaEnvioPedido varchar(100),    
					IdPeticionOferta int,    
					RecepcionServicio bit,    
					FechaRecepcionServicio varchar(100),  
					IdPedidoGeneral	int,
					Cerrado	bit,
					ProveedorVentaId int,
					EstatusAprobacion	varchar(100),
					IdEstatus int,
					SolitudCreadaEl	varchar(100),
					CreadoPor varchar(500),
					Contrato varchar(500),
					SolitanteRequisicion			varchar(300),
					IdAceptacionPedido int,
					x int,
					IdFlujoTarea int,
					IdTarea int,
					IdEstatus2 int,
					PO varchar(100)
					)
					    						
	    IF @Filtro ='TODAS'
		BEGIN 
		 
		SELECT	    SAP.IdSolicitudAceptacionPedido,
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
					SAP.IdAceptacionPedido   ,
					ISNULL(RPO.PO,'Sin PO relacionada') AS PO
		FROM		MM_SolicitudAceptacionPedido			SAP (NOLOCK)
		JOIN		TA_Operacion							O (NOLOCK)
		ON			SAP.IdSolicitudAceptacionPedido			=	O.IdDocumento
		AND			SAP.Activo								=	1
		AND			O.IdTipoOperacion						=	@TipoOperacionId -->CTE 20
		JOIN		TA_Estatus								E (NOLOCK)
		ON			O.IdEstatusOperacion					=	E.IdEstatus
		JOIN		MM_Pedido								P (NOLOCK)
		ON			SAP.IdPedido							=	P.IdPedido
		AND			P.IdProveedorCompras					=	@IdProveedor
		JOIN		MM_Pedidos								PG (NOLOCK)
		ON			P.IdPedido								=	PG.IdIdentificador 
		AND			P.IdProveedorCompras					=	PG.IdProveedorCliente						
		AND			PG.IdTipoPedido							in	(2,4,6) --> CTES
		LEFT JOIN	S_Proveedor								PC (NOLOCK)
		ON			P.IdSubcontratista						=	PC.IdProveedor
		LEFT JOIN	S_Usuario								UE (NOLOCK)
		ON			SAP.CreadorPor							=	UE.IdUsuario
		LEFT JOIN	Adinco..CO_Contrato						C (NOLOCK)
		ON			P.IdContrato							=	C.IdContrato
		LEFT JOIN	Adinco..CO_AreaContractual				AC (NOLOCK)
		ON			C.IdAreaContractual						=	AC.IdAreaContractual
		LEFT JOIN	MM_SolicitudPedido						SP (NOLOCK)
		ON			P.IdSolicitudPedido						=	SP.IdSolicitudPedido
		LEFT JOIN	S_Usuario								US (NOLOCK)
		ON			SP.Solicitante							=	US.IdUsuario
		left join	TA_Tarea								ta (NOLOCK)
		on			ta.IdOperacion							=	O.IdOperacion
		and			ta.IdAprobador							=	@IdUsuario
		LEFT JOIN	DEA_Relacion_PR_PO AS RPO	(NOLOCK)
		ON			P.IdPedido								= RPO.IdPedido
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
					 SAP.IdAceptacionPedido,
					 RPO.PO
		ORDER BY	SAP.IdSolicitudAceptacionPedido DESC	    	    
	END 

	IF @Filtro ='EN-APROBACION'
	 BEGIN 
	 insert into #AprobacionesOBSyRequisitor
		(IdSolicitudAceptacionPedido,
					Comentario,
					IdPedido,    
					IdSolicitudPedido,    		 
					Proveedor,    
					FechaEnvioPedido,    
					IdPeticionOferta,    
					RecepcionServicio,    
					FechaRecepcionServicio,  
					IdPedidoGeneral,
					Cerrado,
					ProveedorVentaId,
					EstatusAprobacion,
					IdEstatus,
					SolitudCreadaEl,
					CreadoPor,
					Contrato,
					SolitanteRequisicion,
					IdAceptacionPedido,
					x,
					IdFlujoTarea,
					IdTarea,
					IdEstatus2,
					PO) 
		SELECT		SAP.IdSolicitudAceptacionPedido,
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
					SAP.IdAceptacionPedido,
					x = case when ((ta.IdAprobador				=	@IdUsuario and ta.IdEstatus = 1)) then 1 when	 ((@esOBS = 1 )  and ta.IdEstatus = 2) then 2 else 0 end,
					IdFlujoTarea,
					ta.IdTarea,
					ta.IdEstatus,
					ISNULL(RPO.PO,'Sin PO relacionada') AS PO
		FROM		MM_SolicitudAceptacionPedido	SAP (NOLOCK)
		JOIN		TA_Operacion					O (NOLOCK)
		ON			SAP.IdSolicitudAceptacionPedido =	O.IdDocumento
		AND			@TipoOperacionId				=	O.IdTipoOperacion -->CTE 20
		AND			1								=	O.IdEstatusOperacion--> EN APROBACION CTE TA_Estatus
		LEFT JOIN		TA_Estatus						E (NOLOCK)
		ON			O.IdEstatusOperacion			=	E.IdEstatus
		JOIN		MM_Pedido						P (NOLOCK)
		ON			SAP.IdPedido					=	P.IdPedido
					AND @IdProveedor				=	P.IdProveedorCompras
		JOIN		MM_Pedidos						PG (NOLOCK)
		ON			P.IdPedido						=	PG.IdIdentificador 
		AND			P.IdProveedorCompras			=	PG.IdProveedorCliente
		AND			PG.IdTipoPedido					in	(2,4,6) -->CTES
		LEFT JOIN	S_Proveedor						PC (NOLOCK)
		ON			P.IdSubcontratista				=	PC.IdProveedor
		LEFT JOIN	S_Usuario						UE (NOLOCK)
		ON			SAP.CreadorPor					=	UE.IdUsuario
		LEFT JOIN	Adinco..CO_Contrato				C (NOLOCK)
		ON			P.IdContrato					=	C.IdContrato
		LEFT JOIN	Adinco..CO_AreaContractual		AC (NOLOCK)
		ON			C.IdAreaContractual				=	AC.IdAreaContractual
		LEFT JOIN	MM_SolicitudPedido				SP (NOLOCK)
		ON			P.IdSolicitudPedido				=	SP.IdSolicitudPedido
		LEFT JOIN	S_Usuario						US (NOLOCK)
		ON			SP.Solicitante					=	US.IdUsuario
		LEFT JOIN	TA_Tarea						ta (NOLOCK)	
		on			O.IdOperacion					= ta.IdOperacion					
		LEFT JOIN	DEA_Relacion_PR_PO AS RPO (NOLOCK)
		ON			P.IdPedido						=  RPO.IdPedido
		WHERE 		P.IdProveedorCompras			=	@IdProveedor
		and			C.IdContrato					=	@IdContrato
		and			O.IdEstatusOperacion			=	1
		--AGREGADO DE ESTE PARAMETRO PARA MOSTRARLE LAS APROBACIONES A LOS OBS
		and			(@esOBS = 1)
		and			ta.NoSecuencia is null
		--COMENTADO PARA ISSUE 1765
		--and			((ta.IdAprobador				=	@IdUsuario and ta.IdEstatus = 1)	or ((@esOBS = 1 )  and ta.IdEstatus = 2) )
		--and			ta.IdEstatus					=   1
		--and			ta.Activo						=	1
		GROUP BY    
					ta.IdTarea,
					IdFlujoTarea,
					ta.IdAprobador,
					ta.IdEstatus,
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
					SAP.IdAceptacionPedido,
					RPO.PO
		ORDER BY	SAP.IdSolicitudAceptacionPedido DESC
		insert into #AprobacionesOBSyRequisitor
		(IdSolicitudAceptacionPedido,
					Comentario,
					IdPedido,    
					IdSolicitudPedido,    		 
					Proveedor,    
					FechaEnvioPedido,    
					IdPeticionOferta,    
					RecepcionServicio,    
					FechaRecepcionServicio,  
					IdPedidoGeneral,
					Cerrado,
					ProveedorVentaId,
					EstatusAprobacion,
					IdEstatus,
					SolitudCreadaEl,
					CreadoPor,
					Contrato,
					SolitanteRequisicion,
					IdAceptacionPedido,
					x,
					IdFlujoTarea,
					IdTarea,
					IdEstatus2,
					PO) 
		SELECT		SAP.IdSolicitudAceptacionPedido,
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
					SAP.IdAceptacionPedido,
					x = case when ((ta.IdAprobador				=	@IdUsuario and ta.IdEstatus = 1)) then 1 when	 ((@esOBS = 1 )  and ta.IdEstatus = 2) then 2 else 0 end,
					IdFlujoTarea,
					ta.IdTarea,
					ta.IdEstatus,
					ISNULL(RPO.PO,'Sin PO relacionada') AS PO
		FROM		MM_SolicitudAceptacionPedido	SAP (NOLOCK)
		JOIN		TA_Operacion					O (NOLOCK)
		ON			SAP.IdSolicitudAceptacionPedido =	O.IdDocumento
		AND			O.IdTipoOperacion				=	@TipoOperacionId -->CTE 20
		AND			O.IdEstatusOperacion			=	1 --> EN APROBACION CTE TA_Estatus
		LEFT JOIN		TA_Estatus						E (NOLOCK)
		ON			O.IdEstatusOperacion			=	E.IdEstatus
		JOIN		MM_Pedido						P (NOLOCK)
		ON			SAP.IdPedido					=	P.IdPedido
					AND P.IdProveedorCompras		=	@IdProveedor
		JOIN		MM_Pedidos						PG (NOLOCK)
		ON			P.IdPedido						=	PG.IdIdentificador 
		AND			PG.IdProveedorCliente			=	P.IdProveedorCompras 
		AND			PG.IdTipoPedido					in	(2,4,6) -->CTES
		LEFT JOIN	S_Proveedor						PC (NOLOCK)
		ON			P.IdSubcontratista				=	PC.IdProveedor
		LEFT JOIN	S_Usuario						UE (NOLOCK)
		ON			SAP.CreadorPor					=	UE.IdUsuario
		LEFT JOIN	Adinco..CO_Contrato				C (NOLOCK)
		ON			P.IdContrato					=	C.IdContrato
		LEFT JOIN	Adinco..CO_AreaContractual		AC (NOLOCK)
		ON			C.IdAreaContractual				=	AC.IdAreaContractual
		LEFT JOIN	MM_SolicitudPedido				SP (NOLOCK)
		ON			P.IdSolicitudPedido				=	SP.IdSolicitudPedido
		LEFT JOIN	S_Usuario						US (NOLOCK)
		ON			SP.Solicitante					=	US.IdUsuario
		LEFT JOIN	TA_Tarea						ta (NOLOCK)	
		on			O.IdOperacion					= ta.IdOperacion					
		LEFT JOIN	DEA_Relacion_PR_PO AS RPO (NOLOCK)
		ON			P.IdPedido						=  RPO.IdPedido
		WHERE 		P.IdProveedorCompras			=	@IdProveedor
		and			C.IdContrato					=	@IdContrato		
		and			((ta.IdAprobador				=	@IdUsuario and ta.IdEstatus = 1)	or ((@esOBS = 1 )  and ta.IdEstatus = 2) )		
		and			ta.Activo						=	1
		GROUP BY    
					ta.IdTarea,
					IdFlujoTarea,
					ta.IdAprobador,
					ta.IdEstatus,
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
					SAP.IdAceptacionPedido,
					RPO.PO
		ORDER BY	SAP.IdSolicitudAceptacionPedido DESC;
		
		select * from #AprobacionesOBSyRequisitor 
		order by IdSolicitudAceptacionPedido
		desc
	 END 
END
