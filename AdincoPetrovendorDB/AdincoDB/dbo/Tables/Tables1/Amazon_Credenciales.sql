CREATE TABLE [dbo].[Amazon_Credenciales] (
    [Id]            INT           IDENTITY (1, 1) NOT NULL,
    [AccessKey]     VARCHAR (350) NULL,
    [SecretKey]     VARCHAR (350) NULL,
    [ServiceUrl]    VARCHAR (350) NULL,
    [DefaultBucket] VARCHAR (350) NULL,
    [IdAplicacion]  INT           NULL,
    [Descrip1]      VARCHAR (350) NULL,
    [Descrip2]      VARCHAR (350) NULL,
    [EsActivo]      BIT           NULL,
    [CreadoEl]      DATETIME      NULL,
    [ModificadoEl]  DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

