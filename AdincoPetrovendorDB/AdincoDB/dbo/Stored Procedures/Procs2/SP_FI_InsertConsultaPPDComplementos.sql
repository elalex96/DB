-- =============================================
-- Author:		Marcos Garcia
-- Create date: 16-06-20201
-- Description:	Insertar a Control de Parcialidades
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_InsertConsultaPPDComplementos] 
-- ============================================= 
@IdFactura  INT, 
@IdContrato INT, 
@IdUsuario  INT
AS
    BEGIN
        IF EXISTS
        (
            SELECT *
            FROM dbo.FI_ComplementoDePago
            WHERE IdFactura = @IdFactura
        )
            BEGIN
                INSERT INTO dbo.FI_ControlPPDComplementos
                (IdFactura, 
                 TipoComprobante, 
                 UUID, 
                 MesPresentacion, 
                 Activo, 
                 IdContrato, 
                 CreadoPor, 
                 CreadoEl
                )
                       SELECT @IdFactura, 
                              F.TipoComprobante, 
                              F.UUID, 
                              MAX(CR.MesPresentacion), 
                              1, 
                              @IdContrato, 
                              @IdUsuario, 
                              GETDATE() F
                       FROM dbo.FI_Factura F
                            JOIN dbo.FI_ComplementoDePago CP ON F.IdFactura = CP.IdFactura
                            LEFT JOIN dbo.FI_CPDocRelacionado DR ON CP.IdComplementoDePago = DR.IdComplementoDePago
                            LEFT JOIN dbo.FI_Factura FI ON DR.IdDocumento = FI.UUID
                            LEFT JOIN dbo.CO_Registro CR ON FI.IdFactura = CR.IdFactura
                       WHERE F.IdFactura = @IdFactura
                       GROUP BY F.TipoComprobante, 
                                F.UUID;
            END;
            ELSE
            BEGIN
                INSERT INTO dbo.FI_ControlPPDComplementos
                (IdFactura, 
                 TipoComprobante, 
                 UUID, 
                 MesPresentacion, 
                 Activo, 
                 IdContrato, 
                 CreadoPor, 
                 CreadoEl
                )
                       SELECT @IdFactura, 
                              F.TipoComprobante, 
                              F.UUID, 
                              MAX(C.MesPresentacion), 
                              1, 
                              @IdContrato, 
                              @IdUsuario, 
                              GETDATE()
                       FROM dbo.FI_Factura F
                            LEFT JOIN dbo.CO_Registro C ON F.IdFactura = C.IdFactura
                       WHERE F.IdFactura = @IdFactura
                       GROUP BY F.TipoComprobante, 
                                F.UUID;
            END;
    END;