USE [Petrovendor]
GO
-- Evaluamos si el SP existe; si es así, lo eliminamos.
DROP PROCEDURE IF EXISTS [dbo].[DEA_ConsultarSolicitudCNProveedorExtranjero];
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 25/04/2026
-- Description:	Consulta los permisos de CN para proveedores extranjeros.
--              Se agrega el retorno de las columnas de auditoría:
--              CreadoPor, CreadoEl, ModificadoPor, ModificadoEl
--              para mostrarlas en el grid de administración.
-- =============================================
CREATE PROCEDURE [dbo].[DEA_ConsultarSolicitudCNProveedorExtranjero]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        s.IdProveedor,
        p.RFC,
        p.RazonSocial as Proveedor,
        s.IdContrato,
        c.NumeroContrato + ' - ' + ac.NombreAreaContractual as Contrato,
        s.CreadoPor,
        s.CreadoEl,
        s.ModificadoPor,
        s.ModificadoEl
    FROM dbo.DEA_SolicitudCNProveedorExtranjero s
    INNER JOIN dbo.S_Proveedor  p ON p.IdProveedor = s.IdProveedor
    INNER JOIN Adinco.dbo.CO_Contrato c ON c.IdContrato  = s.IdContrato
    INNER JOIN Adinco.dbo.CO_AreaContractual ac ON c.IdAreaContractual = ac.IdAreaContractual
END
GO