-- =============================================
-- Author:	Reyna Olvera
-- Create date:25/06
-- Description:	Extrae las actividades
-- =============================================
-- Modificado Por:	Neri Garcia
-- Fecha:			17 de Agosto del 2022
-- Descripción:		Eliminación de código comentado, agregado de (NOLOCK), ajuste en el nombrado de las tablas
-- =============================================
CREATE PROCEDURE [dbo].[sp_FI_ExtraeErroresFacturas]
    @idContrato INT,
    @idUsuario INT,
    @Error VARCHAR(1000)
AS
BEGIN
    SET NOCOUNT ON;
	/**/
    INSERT INTO FI_ErroresCargaFactura
    (
        Error,
        IdContrato,
        CreadoPor,
        CreadoEl,
        ModificadoPor,
        ModificadoEl,
        Activo
    )
    VALUES
    (
		@Error, 
		@idContrato,
		@idUsuario, 
		GETDATE(), 
		@idUsuario, 
		GETDATE(), 
		1
	);
	/**/
    IF (@Error LIKE '%existe%')
    BEGIN

        SELECT '<div class="alert alert-danger alert-dismissable">
					<button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>
                                 <strong>Alerta! </strong>' + REPLACE(@Error, 'Excepción:', '') + ', en el contrato'
               + CO_Contrato.NumeroContrato + ' </div>' AS error
        FROM FI_Factura (NOLOCK)
            JOIN CO_Contrato (NOLOCK)
                ON FI_Factura.IdContrato = CO_Contrato.IdContrato
        WHERE FI_Factura.UUID = REPLACE(@Error, 'Error:Excepción: La factura que desea insertar ya existe UUID: ', '');

    END
	/**/
    ELSE
    BEGIN
        SELECT '<div class="alert alert-danger alert-dismissable">
					<button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>
                                 <strong>Alerta! </strong>' + REPLACE(@Error, 'Excepción:', '') + ' </div>' AS error;
    END;
END;