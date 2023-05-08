-- =============================================
-- Author:		Marcos Garcia
-- Create date: 15-06-2020
-- Description:	Consulta de Control de Parcialidades
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ControlPPDComplementos] 
-- ============================================= 
--[SP_FI_ControlPPDComplementos] 3,0
-- ============================================= 
@IdContrato INT, 
@IdUsuario  INT
AS
     BEGIN
         -- =============================================  
         SET LANGUAGE Spanish;
         SELECT CPC.IdControlPPDC, 
                CPC.IdFactura, 
                UPPER(CPC.TipoComprobante) TipoComprobante, 
                UPPER(CPC.UUID) UUID,
                CASE
                    WHEN(CPC.MesPresentacion IS NULL)
                    THEN 'Sin Especificar'
                    ELSE DATENAME(MONTH, CPC.MesPresentacion)+' de '+CONVERT(NVARCHAR(MAX), DATENAME(YEAR, CPC.MesPresentacion))
                END AS MesPresentacion, 
                CPC.Activo, 
                UC.Nombre AS CreadoPor, 
                CPC.CreadoEl, 
                UM.Nombre AS ModificadoPor, 
                CPC.ModificadoEl
         FROM dbo.FI_ControlPPDComplementos CPC
              LEFT JOIN dbo.AP_Usuario UC ON CPC.CreadoPor = UC.UsuarioID
              LEFT JOIN dbo.AP_Usuario UM ON CPC.ModificadoPor = UM.UsuarioID
         WHERE CPC.IdContrato = @IdContrato
         ORDER BY CPC.IdControlPPDC DESC;
         -- =============================================
     END;

