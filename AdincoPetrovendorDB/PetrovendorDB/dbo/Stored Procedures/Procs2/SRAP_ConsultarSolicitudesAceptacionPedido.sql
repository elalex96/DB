USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SRAP_ConsultarSolicitudesAceptacionPedido'
)
    DROP PROCEDURE SRAP_ConsultarSolicitudesAceptacionPedido;
	GO
/****** Object:  StoredProcedure [dbo].[SRAP_ConsultarSolicitudesAceptacionPedido]    Script Date: 08/06/2022 03:15:13 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel AC
-- Create date: 25-05-2021
-- Description:	Consultar solicitudes de recepción de pedido
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
		ORDER BY	SAP.IdSolicitudAceptacionPedido DESC	    
		END 
END
