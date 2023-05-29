USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'p_CO_SAP_NotificacionAprobacionInfo'
)
    DROP PROCEDURE p_CO_SAP_NotificacionAprobacionInfo;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 10/05/2023
-- Description:	se agrega el filtrado por usuario activo, nolocks y reacomodo de joins
-- =============================================
CREATE proc [dbo].[p_CO_SAP_NotificacionAprobacionInfo]
@pIdContrato int,
@pSAPPONumber varchar(20),
@pItemNumber	smallint
as

	declare @pVendorIDSAP varchar(20)

	select @pVendorIDSAP = SAPVendorNumber from Adinco..[CO_SAPPO]
	where SAPPONumber = @pSAPPONumber and
	ItemNumber = @pItemNumber and
	IdCOntrato = @pIdContrato

	select top 10 
		Destinatario = ISNULL(u.Correo,'')+';',
		NombreUsuario = prov.RazonSocial,
		IdUsuario = u.idUsuario,
		AreContractual = ac.NombreAreaContractual
	from Adinco..CO_SAPVendor v (NOLOCK)
	INNER JOIN S_Proveedor prov (NOLOCK)
		on v.TaxID COLLATE SQL_Latin1_General_CP1_CI_AS = prov.RFC COLLATE SQL_Latin1_General_CP1_CI_AS 
		AND v.idContrato = @pidContrato
	INNER JOIN S_UsuarioProveedor up (NOLOCK)
		on prov.IdProveedor = up.idProveedor
	INNER JOIN S_Usuario u (NOLOCK)
		on up.IdUsuario = u.idUsuario
			AND u.Activo = 1
	INNER JOIN Adinco..Co_Contrato c (NOLOCK)
		on c.IdCOntrato = @pIdContrato
	INNER JOIN Adinco..CO_AreaContractual ac (NOLOCK)
		on c.IdAreaContractual = ac.IdAreaContractual
	where VendorIDSAP = @pVendorIDSAP


