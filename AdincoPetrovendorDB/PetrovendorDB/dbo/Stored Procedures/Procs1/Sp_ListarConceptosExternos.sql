CREATE PROCEDURE [dbo].[Sp_ListarConceptosExternos] (@IdProveedor INT)
AS
BEGIN
    SELECT desgloce.IdTicket,
           ticket.FechaCreacion,
           prove.RazonSocial, 
		   ticket.IdRazonSocialProveedor,
           desgloce.Folio,
           desgloce.Cantidad,
           desgloce.Descripcion,
           desgloce.ValorUnitario,
           desgloce.Importe
    FROM dbo.PV_Ticket ticket
        INNER JOIN dbo.Pv_TicketDesgloce desgloce
            ON desgloce.IdTicket = ticket.IdTicket
        INNER JOIN dbo.S_UsuarioProveedor uProve
            ON uProve.IdUsuario = ticket.CreadoPor
        INNER JOIN dbo.S_Proveedor prove
            ON prove.IdProveedor = ticket.IdRazonSocialProveedor
    WHERE uProve.IdProveedor = @IdProveedor
	
END

