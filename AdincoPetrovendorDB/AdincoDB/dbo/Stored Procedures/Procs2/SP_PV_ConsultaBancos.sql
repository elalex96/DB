-- =============================================
-- Author:		Marcos Garcia
-- Create date: 20-01-2020
-- Description:	Selección de PV Bancos 
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_ConsultaBancos]
-- Add the parameters for the stored procedure here
@IdContrato INT, 
@IdUsuario  INT, 
@BancoId    INT
AS
     BEGIN
         SET NOCOUNT ON;
         IF(@BancoId = 0)
             BEGIN
                 SELECT B.BancoID, 
                        B.Banco, 
                        B.Clave, 
                        B.RazonSocial,
                        CASE
                            WHEN B.Nacional = 1
                            THEN 'Nacional'
                            ELSE 'Extranjero '
                        END AS Nacional, 
                        UC.Nombre AS CreadoPor, 
                        CONVERT(DATE, B.CreadoEn) AS CreadoEn, 
                        UM.Nombre AS ModificadoPor, 
                        CONVERT(DATE, B.ModificadoEn) AS ModificadoEn
                 FROM dbo.PV_Banco B
                      LEFT JOIN dbo.AP_Usuario UC ON B.CreadoPor = UC.UsuarioID
                      LEFT JOIN dbo.AP_Usuario UM ON B.ModificadoPor = UM.UsuarioID
                 ORDER BY B.BancoID DESC;
             END;
             ELSE
             BEGIN
                 SELECT Banco, 
                        Clave, 
                        RazonSocial, 
                        Nacional
                 FROM dbo.PV_Banco
                 WHERE BancoID = @BancoId;
             END;
     END;