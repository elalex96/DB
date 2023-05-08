-- =============================================
-- Author:		Manuel Cruz
-- Create date: 23-06-2020
-- Description:	
-- =============================================
CREATE PROCEDURE SP_AWSCredenciales 
-- Add the parameters for the stored procedure here
@IdContrato INT, 
@IdUsuario  INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
         IF OBJECT_ID('tempdb..#Credenciales', 'U') IS NOT NULL
             DROP TABLE #Credenciales;
         CREATE TABLE #Credenciales
         (Id              INT IDENTITY, 
          Bucket          VARCHAR(500), 
          AccessKey       VARCHAR(500), 
          SecretAccessKey VARCHAR(500), 
          serviceURL      VARCHAR(500)
         );
         INSERT INTO #Credenciales(Bucket)
                SELECT Name
                FROM dbo.AWS_Bucket
                WHERE IdBucket = 10001;
         --
         UPDATE #Credenciales
           SET 
               AccessKey = U.AccessKey, 
               SecretAccessKey = U.SecretAccessKey
         FROM dbo.AWS_UserIAM AS U
         WHERE #Credenciales.Id = 1
               AND U.IdIAM = 10001;
         --
         UPDATE #Credenciales
           SET 
               serviceURL = S.URL
         FROM dbo.AWS_ServiceUrl AS S
         WHERE Id = 1;
         --
         SELECT Id, 
                Bucket, 
                AccessKey, 
                SecretAccessKey, 
                serviceURL, 
                'ENIArchivos' AS Folder
         FROM #Credenciales;
     END;
--EXEC SP_AWSCredenciales 0,0
