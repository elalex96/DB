-- =============================================
-- Author:		Marcos Garcia
-- Create date: 20-01-2020
-- Description:	Insertar Nuevo dato en PV_Banco
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_InsertarBanco]
-- Add the parameters for the stored procedure here
@Banco       NVARCHAR(MAX), 
@Clave       VARCHAR(10), 
@RazonSocial NVARCHAR(MAX), 
@Nacional    BIT, 
@IdContrato  INT, 
@IdUsuario   INT
AS
     BEGIN
         SET NOCOUNT ON;
         BEGIN
             INSERT INTO dbo.PV_Banco
             (Banco, 
              Clave, 
              RazonSocial, 
              Nacional, 
              CreadoPor, 
              CreadoEn, 
              ModificadoPor, 
              ModificadoEn
             )
             VALUES
             (@Banco, -- Banco - varchar(max)
              @Clave, -- Clave - varchar(10)
              @RazonSocial, -- RazonSocial - nvarchar(max)
              @Nacional, -- Nacional - bit
              @IdUsuario, -- CreadoPor - int
              GETDATE(), -- CreadoEn - datetime
              NULL, -- ModificadoPor - int
              NULL  -- ModificadoEn - datetime
             );
         END;
         IF @@ERROR <> 0
             SELECT 'false' AS msj;
             ELSE
         SELECT 'true' AS msj;
     END;