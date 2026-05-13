CREATE TABLE [dbo].[TA_Office_Servers] (
    [Id]            INT           IDENTITY (1, 1) NOT NULL,
    [Descripcion]   VARCHAR (300) NULL,
    [Client_Id]     VARCHAR (300) NULL,
    [Client_Secret] VARCHAR (300) NULL,
    [Tenant]        VARCHAR (300) NULL,
    [OfficeUser]    VARCHAR (300) NULL,
    [Server]        VARCHAR (300) NULL,
    [LoginUri]      VARCHAR (300) NULL,
    [TokenUri]      VARCHAR (300) NULL,
    [IdContratista] INT           NULL,
    CONSTRAINT [PK_Office_Servers] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_TA_Office_Servers_CO_Contratista] FOREIGN KEY ([IdContratista]) REFERENCES [dbo].[CO_Contratista] ([IdContratista])
);

