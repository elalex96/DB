CREATE TABLE [dbo].[CP_MetodoCalculoHidrocarburoMes] (
    [IdMetodoCalculoHidrocarburoMes] INT            IDENTITY (10000, 1) NOT NULL,
    [IdContrato]                     INT            NULL,
    [IdTipoHidrocarburo]             INT            NULL,
    [IdMetodo]                       INT            NULL,
    [Mes]                            DATE           NULL,
    [Precio]                         MONEY          NULL,
    [Valor]                          MONEY          NULL,
    [Volumen]                        INT            NULL,
    [TasaRegalia]                    FLOAT (53)     NULL,
    [UrlImgRegalia]                  NVARCHAR (MAX) NULL,
    FechaCreacion DATETIME, 
    CreadoPor INT, 
    FechaModificacion DATETIME, 
    ModificadoPor INT,
    FOREIGN KEY (CreadoPor) REFERENCES AP_USUARIO(UsuarioId),
    FOREIGN KEY (ModificadoPor) REFERENCES AP_USUARIO(UsuarioId),
    CONSTRAINT [PK_CP_MetodoCalculoHidrocarburoMes] PRIMARY KEY CLUSTERED ([IdMetodoCalculoHidrocarburoMes] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);


GO
-- =============================================
-- Author:		Miguel Gomez
-- Create date: 
-- Description:	
-- =============================================
CREATE TRIGGER dbo.Trigger_ValorContractual 
   ON  dbo.CP_MetodoCalculoHidrocarburoMes 
   AFTER INSERT,UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	BEGIN TRY  
    -- Generate divide-by-zero error.  
  update CP_MetodoCalculoHidrocarburoMes set Valor= Precio* Volumen;
END TRY  
BEGIN CATCH  
    -- Execute error retrieval routine.  
   
END CATCH; 

    -- Insert statements for trigger here

END
